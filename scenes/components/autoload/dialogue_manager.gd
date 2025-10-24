extends Node


var dialogue_scenes : Dictionary
var scene_segments : Dictionary
var speaker_name : String
var speaker_emotion : String
var segment_dialogue : String
var responses : Dictionary
var next_segment : String


func _ready() -> void:
	EventBus.dialogue_segment_finished.connect(_on_dialogue_segment_finished)
	var parser = XMLParser.new()
	parser.open("res://scenes/components/dialogue/dialogue_scenes.xml")
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			if parser.get_node_name() == "dialogue_scenes":
				continue
			else:
				dialogue_scenes[parser.get_node_name()] = parser.get_node_offset()
				parser.skip_section()
				
	#print(dialogue_scenes)


func load_dialogue_scene(scene_name : String) -> void:
	EventBus.swap_control_state.emit()
	scene_segments.clear()
	var parser = XMLParser.new()
	parser.open("res://scenes/components/dialogue/dialogue_scenes.xml")
	parser.seek(dialogue_scenes.get(scene_name))
	while parser.read() != ERR_FILE_EOF and !(parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == scene_name):
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			if parser.get_node_name() == scene_name:
				continue
			else:
				scene_segments[parser.get_node_name()] = parser.get_node_offset()
				parser.skip_section()
				
	#print(scene_segments)
	dialog_builder(scene_segments.keys()[0])
	
	
func dialog_builder(segment_name : String) -> void:
	next_segment = ""
	var parser = XMLParser.new()
	parser.open("res://scenes/components/dialogue/dialogue_scenes.xml")
	parser.seek(scene_segments.get(segment_name))
	while parser.read() != ERR_FILE_EOF and !(parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == segment_name):
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			match parser.get_node_name():
				"speaker":
					while parser.read() != ERR_FILE_EOF and !(parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == "speaker"):
						if parser.get_node_type() == XMLParser.NODE_ELEMENT:
							match parser.get_node_name():
								"name":
									if parser.read() != ERR_FILE_EOF and parser.get_node_type() == XMLParser.NODE_TEXT:
										speaker_name = parser.get_node_data().strip_escapes()
									else:
										print("uh oh")
								"emotion":
									if parser.read() != ERR_FILE_EOF and parser.get_node_type() == XMLParser.NODE_TEXT:
										speaker_emotion = parser.get_node_data().strip_escapes()
									else:
										print("uh oh!")
				"message":
					if parser.read() != ERR_FILE_EOF and parser.get_node_type() == XMLParser.NODE_TEXT:
						segment_dialogue = parser.get_node_data().strip_escapes()
					else:
						print("uh oh!!")
				"player_responses":
					print("player responses")
				"next_segment":
					if !parser.is_empty():
						if parser.read() != ERR_FILE_EOF and parser.get_node_type() == XMLParser.NODE_TEXT:
							next_segment = parser.get_node_data().strip_escapes()
						else:
							print("uh oh!!!!")
					
	#print(speaker_name)
	#print(speaker_emotion)
	#print(segment_dialogue)
	#print(next_segment)
	#print("\n\n")
	
	EventBus.dialogue_segment_parsed.emit(speaker_name, speaker_emotion, segment_dialogue, responses, next_segment)


func _on_dialogue_segment_finished(next_up: String) -> void:
	if !next_up.is_empty():
		dialog_builder(next_up)
	
	#while parser.read() != ERR_FILE_EOF and !(parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == scene_name):
		#var message = ""
		#if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			#message += "/"
		#
		#if parser.get_node_type() == XMLParser.NODE_ELEMENT or parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			#message += parser.get_node_name()
		#
		#elif parser.get_node_type() == XMLParser.NODE_TEXT:
			#if (!parser.get_node_data().strip_escapes().is_empty()):
				#message += parser.get_node_data().strip_edges()
			#else:
				#continue
		#
		#else:
			#message += "[ELSE]"
		#
		#print(message)
