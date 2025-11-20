class_name Dialogue
extends CanvasLayer


signal finished #TODO This signal is probably vestigal at this point.
@warning_ignore("unused_signal")
signal fileRead

@export var time_between_characters = 0.04 #Number of seconds between characters in textbox

var fullVis = true #Denotes if the full loaded text is visible
var player_talking = true
var talking_accelerated = false
var working_dialog
var working_text : RichTextLabel
var working_text_length : int
var working_speaker : TextureRect
var response_options : Dictionary
var next_segment : String

@onready var typingTimer := $typingTimer
@onready var audio := $AudioStreamPlayer


func _ready():
	EventBus.dialogue_segment_parsed.connect(designate_dialog)
	visible = false
	$LeftSideDialog.visible = false
	$RightSideDialog.visible = false
	$GenericDialog.visible = false
	$ResponseDialog.visible = false
	typingTimer.wait_time = time_between_characters


func designate_dialog(speaker:String, emotion:String, side:String, dialogue_text:String, responses:Dictionary, next_seg:String) -> void: # TODO: Add general information dialog (Player, other person, information)
	typingTimer.wait_time = time_between_characters
	next_segment = next_seg
	response_options = responses.duplicate()
	var headshot_path := "res://assets/visual/speaker_headshots/"
	var voice_path := "res://assets/audio/speaker_voices/"
	if side == "left":
		working_dialog = $LeftSideDialog
		working_text = $LeftSideDialog/HBoxContainer/Text
		working_speaker = $LeftSideDialog/HBoxContainer/Speaker
	elif side == "right":
		working_dialog = $RightSideDialog
		working_text = $RightSideDialog/HBoxContainer/Text
		working_speaker = $RightSideDialog/HBoxContainer/Speaker
	else:
		working_dialog = $GenericDialog
		working_text = $GenericDialog/HBoxContainer/Text
		working_speaker = null
	working_dialog.visible = true
	
	if working_speaker != null:
		headshot_path = headshot_path + speaker + "/" + emotion + ".png"
		voice_path = voice_path + speaker + "/" + emotion + ".wav"
		working_speaker.texture = load(headshot_path)
	elif speaker != null and emotion != null:
		voice_path = voice_path + speaker + "/" + emotion + ".wav"
	else:
		voice_path = voice_path + "generic.wav"
	
	audio.stream = AudioStreamWAV.load_from_file(voice_path)
	
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	var text_without_tags = regex.sub(dialogue_text, "", true)
	working_text_length = text_without_tags.length()
	update_message(dialogue_text)


func designate_responses() -> void:
	for i in range(4):
		var button:Button = $ResponseDialog/VBoxContainer.get_child(i)
		button.text = ""
		button.visible = false
	
	for i in range(response_options.size()):
		var choices = response_options.keys()
		var choice = choices.get(i)
		var button:Button = $ResponseDialog/VBoxContainer.get_child(i)
		button.text = response_options[choice]
		button.visible = true
		button.button_down.connect(_choice_made.bind(choice))
		
	$ResponseDialog/VBoxContainer/ChoiceOne.grab_focus()
	$ResponseDialog.visible = true

func update_message(message: String) -> void:
	fullVis = false #The text is no longer fully visible, as a new message is being written
	working_text.visible_characters = 0 #"Clear" the text (effectively just making it invisible)
	working_text.bbcode_text = message #"Prepare" the new text (effectively replace what's there)
	if not visible: #If the dialogue box isn't visible, make it so.
		visible = true
	typingTimer.start() #Start the character typing timer
	audio.play()


func _on_typing_timer_timeout() -> void: #Every time_between_characters seconds
	#print("_on_typing_timer_timeout2 called")
	if working_text.visible_characters <= working_text_length: #If the number of visible characters is less than the total
		working_text.visible_characters += 1 #Add one to the former
	else:
		fullVis = true #Otherwise, the text is all written
		typingTimer.stop()
		await EventBus.interact
		working_dialog.visible = false
		talking_accelerated = false
		if !response_options.is_empty():
			designate_responses()
			return
		if next_segment.is_empty():
			$LeftSideDialog.visible = false
			$RightSideDialog.visible = false
			$GenericDialog.visible = false
			EventBus.swap_control_state.emit()
			EventBus.finish_dialogue.emit(DialogueManager.current_scene)
		EventBus.dialogue_segment_finished.emit(next_segment)
		emit_signal("finished") #TODO probably vestigal


func _accelerate_reading_speed():
	typingTimer.wait_time = time_between_characters / 5.0


func _choice_made(choice: String):
	$ResponseDialog.visible = false
	EventBus.dialogue_segment_finished.emit(choice)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and !typingTimer.is_stopped() and !talking_accelerated:
		_accelerate_reading_speed()


#func update_message(_message: String) -> void:
	#pass
	##fullVis = false #The text is no longer fully visible, as a new message is being written
	##text.visible_characters = 0 #"Clear" the text (effectively just making it invisible)
	##text.bbcode_text = message #"Prepare" the new text (effectively replace what's there)
	##if not visible: #If the dialogue box isn't visible, make it so.
		##visible = true
	##typingTimer.start() #Start the character typing timer
#
#func _on_typing_timer_timeout() -> void: #Every time_between_characters seconds
	#pass
	##if text.visible_characters < text.text.length(): #If the number of visible characters is less than the total
		##text.visible_characters += 1 #Add one to the former
	##else:
		##fullVis = true #Otherwise, the text is all written
		##typingTimer.stop()
		##emit_signal("finished") #TODO probably vestigal
#
#var f : FileAccess
#var choices : Dictionary = {}
#
#func openFile(file): #Opens provided file for reading
	#f = FileAccess.open(file, FileAccess.READ)
#
#func readFile(): #Reads file
	#if fullVis: #If the current line is fully written
		#var temp = nextLine() #Scan the next line
		#if temp.size() > 0: #If there is at least a command
			#if temp[0] == "EOF": #If that command is "EOF", close the file, hide the box, re-enable movement
				#f.close()
				#visible = false
				#EventBus.emit_signal("fileRead")
			#if temp[0] == "LINE": #If that command is "LINE", update the box with the current line
				#update_message(temp[1])
				#await(finished)
	#else: #If the current line isn't fully written
		#text.visible_characters = text.text.length() #Snap it to the full text
		#fullVis = true #Set fully visible to true
		#typingTimer.stop() #Turn off the character typing
		#emit_signal("finished") #Signal the line is finished TODO probably vestigal
#
#func nextLine() -> Array: #Scan next line and split into command and text
	#var line = f.get_line() 
	#var tagLine = line.split(" ", false, 1) #split into command and text (Ex, the line "LINE Hello" would be split into "LINE" and "Hello", denoting a simple written line
	#return tagLine
