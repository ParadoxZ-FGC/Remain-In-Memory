extends Node


@export var dialogue_scene : String

var dialogue_scenes : Dictionary


func _ready() -> void:
	var parser = XMLParser.new()
	parser.open("res://scenes/components/dialogue/dialogue_scenes.xml")
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			if parser.get_node_name() == "dialogue_scenes":
				continue
			else:
				dialogue_scenes[parser.get_node_name()] = parser.get_node_offset()
				parser.skip_section()
	
	scene_reader(dialogue_scene)
	
	var timer = get_tree().create_timer(0.1)
	await timer.timeout
	get_tree().quit()
	

func scene_reader(key_name):
	var parser = XMLParser.new()
	parser.open("res://scenes/components/dialogue/dialogue_scenes.xml")
	parser.seek(dialogue_scenes.get(key_name))
	while parser.read() != ERR_FILE_EOF and !(parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == key_name):
		var message = ""
		if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			message += "/"
		
		if parser.get_node_type() == XMLParser.NODE_ELEMENT or parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			message += parser.get_node_name()
		
		elif parser.get_node_type() == XMLParser.NODE_TEXT:
			if (!parser.get_node_data().strip_escapes().is_empty()):
				#message += parser.get_node_data().strip_edges()
				message += parser.get_node_data().xml_unescape().strip_edges()
			else:
				continue
		
		else:
			message += "[ELSE]"
		
		print(message)

#func _ready() -> void:
	#var parser = XMLParser.new()
	#parser.open("res://scenes/components/dialogue/dialogueTesting/test.xml")
	#print("[SOF]")
	#while parser.read() != ERR_FILE_EOF:
		#var message = String.num_int64(parser.get_current_line()) + "\t"
		#if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			#message += "/"
		#
		#if parser.get_node_type() == XMLParser.NODE_ELEMENT or parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			#message += parser.get_node_name()
		#
		#elif parser.get_node_type() == XMLParser.NODE_TEXT:
			#if (!parser.get_node_data().strip_escapes().is_empty()):
				#message += "  " + parser.get_node_data().strip_escapes()
			#else:
				#continue
		#
		#else:
			#message += "[ELSE]"
		#
		#print(message)
		#
	#print("[EOF]")
