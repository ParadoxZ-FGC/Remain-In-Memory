class_name Dialogue
extends CanvasLayer

@onready var text = $Background/Text
@onready var bg = $Background
@onready var typingTimer = $typingTimer
@export var typingSpeed = 0.04 #Number of seconds between characters in textbox
var fullVis = true #Denotes if the full loaded text is visible

signal finished #TODO This signal is probably vestigal at this point.
signal fileRead

func _ready():
	visible = false
	typingTimer.wait_time = typingSpeed

func update_message(message: String) -> void:
	fullVis = false #The text is no longer fully visible, as a new message is being written
	text.visible_characters = 0 #"Clear" the text (effectively just making it invisible)
	text.bbcode_text = message #"Prepare" the new text (effectively replace what's there)
	if not visible: #If the dialogue box isn't visible, make it so.
		visible = true
	typingTimer.start() #Start the character typing timer

func _on_typing_timer_timeout() -> void: #Every typingSpeed seconds
	if text.visible_characters < text.text.length(): #If the number of visible characters is less than the total
		text.visible_characters += 1 #Add one to the former
	else:
		fullVis = true #Otherwise, the text is all written
		typingTimer.stop()
		emit_signal("finished") #TODO probably vestigal

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
