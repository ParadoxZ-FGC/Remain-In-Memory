class_name Dialogue
extends CanvasLayer

@onready var text = $OtherDialog/HBoxContainer/Text
@onready var bg = $OtherDialog
@onready var typingTimer = $typingTimer
@export var time_between_characters = 0.04 #Number of seconds between characters in textbox

var fullVis = true #Denotes if the full loaded text is visible
var player_talking = true
var talking_accelerated = false
var working_dialog
var working_text
var working_text_length : int
var working_speaker
var next_segment : String

signal finished #TODO This signal is probably vestigal at this point.
@warning_ignore("unused_signal")
signal fileRead

func _ready():
	EventBus.dialogue_segment_parsed.connect(designate_dialog)
	visible = false
	$OtherDialog.visible = false
	$PlayerDialog.visible = false
	typingTimer.wait_time = time_between_characters


func designate_dialog(speaker:String, _emotion:String, dialogue_text:String, _responses:Dictionary, next_seg:String) -> void: # TODO: Add general information dialog (Player, other person, information)
	typingTimer.wait_time = time_between_characters
	next_segment = next_seg 
	player_talking = speaker == "Traveler"
	if player_talking:
		working_dialog = $PlayerDialog
		working_text = $PlayerDialog/HBoxContainer/Text
		working_speaker = $PlayerDialog/HBoxContainer/Speaker
	else:
		working_dialog = $OtherDialog
		working_text = $OtherDialog/HBoxContainer/Text
		working_speaker = $OtherDialog/HBoxContainer/Speaker
	working_dialog.visible = true
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	var text_without_tags = regex.sub(dialogue_text, "", true)
	working_text_length = text_without_tags.length()
	update_message2(dialogue_text)


func update_message2(message: String) -> void:
	fullVis = false #The text is no longer fully visible, as a new message is being written
	working_text.visible_characters = 0 #"Clear" the text (effectively just making it invisible)
	working_text.bbcode_text = message #"Prepare" the new text (effectively replace what's there)
	if not visible: #If the dialogue box isn't visible, make it so.
		visible = true
	typingTimer.start() #Start the character typing timer


func update_message(_message: String) -> void:
	pass
	#fullVis = false #The text is no longer fully visible, as a new message is being written
	#text.visible_characters = 0 #"Clear" the text (effectively just making it invisible)
	#text.bbcode_text = message #"Prepare" the new text (effectively replace what's there)
	#if not visible: #If the dialogue box isn't visible, make it so.
		#visible = true
	#typingTimer.start() #Start the character typing timer


func _on_typing_timer_timeout2() -> void: #Every time_between_characters seconds
	#print("_on_typing_timer_timeout2 called")
	if working_text.visible_characters <= working_text_length: #If the number of visible characters is less than the total
		working_text.visible_characters += 1 #Add one to the former
	else:
		fullVis = true #Otherwise, the text is all written
		typingTimer.stop()
		await EventBus.continue_dialogue
		working_dialog.visible = false
		talking_accelerated = false
		if next_segment.is_empty():
			$OtherDialog.visible = false
			$PlayerDialog.visible = false
			EventBus.swap_control_state.emit()
			EventBus.finish_cutscene.emit()
		EventBus.dialogue_segment_finished.emit(next_segment)
		emit_signal("finished") #TODO probably vestigal


func _on_typing_timer_timeout() -> void: #Every time_between_characters seconds
	pass
	#if text.visible_characters < text.text.length(): #If the number of visible characters is less than the total
		#text.visible_characters += 1 #Add one to the former
	#else:
		#fullVis = true #Otherwise, the text is all written
		#typingTimer.stop()
		#emit_signal("finished") #TODO probably vestigal

var f : FileAccess
var choices : Dictionary = {}

func openFile(file): #Opens provided file for reading
	f = FileAccess.open(file, FileAccess.READ)

func readFile(): #Reads file
	if fullVis: #If the current line is fully written
		var temp = nextLine() #Scan the next line
		if temp.size() > 0: #If there is at least a command
			if temp[0] == "EOF": #If that command is "EOF", close the file, hide the box, re-enable movement
				f.close()
				visible = false
				EventBus.emit_signal("fileRead")
			if temp[0] == "LINE": #If that command is "LINE", update the box with the current line
				update_message(temp[1])
				await(finished)
	else: #If the current line isn't fully written
		text.visible_characters = text.text.length() #Snap it to the full text
		fullVis = true #Set fully visible to true
		typingTimer.stop() #Turn off the character typing
		emit_signal("finished") #Signal the line is finished TODO probably vestigal

func nextLine() -> Array: #Scan next line and split into command and text
	var line = f.get_line() 
	var tagLine = line.split(" ", false, 1) #split into command and text (Ex, the line "LINE Hello" would be split into "LINE" and "Hello", denoting a simple written line
	return tagLine


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and typingTimer.time_left > 0 and !talking_accelerated:
		_accelerate_reading_speed()


func _accelerate_reading_speed():
	typingTimer.wait_time = time_between_characters / 5.0
