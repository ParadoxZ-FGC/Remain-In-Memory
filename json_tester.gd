extends Node


var json : JSON


func _ready() -> void:
	_read("res://dialogue_scenes.json")
	#_make()
	pass


func _make():
	json = JSON.new()
	
	var file = FileAccess.open("res://test.json", FileAccess.WRITE_READ)
	
	var dict = {
		"intro_campfire" : {
			"crackles" : {
				"speaker" : {
					"name":"",
					"emotion":"",
					"side":""
				},
				"message":"The campfire crackles and pops.",
				"player_responses":"",
				"next_segment":"warmth"
			},
			"warmth" : {
				"speaker": {
					"name":"",
					"emotion":"",
					"side":""
				},
				"message":"It fills you with warmth for your journey ahead.",
				"player_responses":"",
				"next_segment":""
			}
		}
	}
	file.store_string(JSON.stringify(dict, "\t", false))


func _read(file_path):
	json = JSON.new()
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var error = json.parse(file.get_as_text())
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_ARRAY:
			print(data_received) # Prints the array.
		elif typeof(data_received) == TYPE_DICTIONARY:
			_print_dict(data_received, 0)
		else:
			print("Unexpected data")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", file.get_as_text(), " at line ", json.get_error_line())


func _print_dict(dict, layer):
	var tab = "\t"
	for key in dict:
		if typeof(dict[key]) == TYPE_DICTIONARY:
			print(tab.repeat(layer), "Key: ", key, " - Value: {")
			_print_dict(dict[key], layer+1)
			print(tab.repeat(layer), "}")
		else:
			print(tab.repeat(layer), "Key: ", key, " - Value: ", dict[key])
