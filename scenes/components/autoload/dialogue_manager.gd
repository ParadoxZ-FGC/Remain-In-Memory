extends Node


@export var dialogue_scenes : Dictionary
@export var current_cutscene : Dictionary
var speaker_name : String
var speaker_emotion : String
var speaker_side : String
var scene_dialogue : String
var responses : Dictionary
var next_scene : Dictionary


func _ready() -> void:
	EventBus.dialogue_segment_finished.connect(_on_dialogue_segment_finished)
	var file = FileAccess.open("res://scenes/components/dialogue/dialogue_scenes.json", FileAccess.READ)
	var _err = FileAccess.get_open_error()
	var json = JSON.new()
	json.parse(file.get_as_text())
	dialogue_scenes = json.data


func load_dialogue_scene(cutscene_name : String) -> void:
	EventBus.swap_control_state.emit()
	current_cutscene.clear()
	current_cutscene.assign(dialogue_scenes.get(cutscene_name))
	
	dialog_builder(current_cutscene.values()[0])


func dialog_builder(scene : Dictionary) -> void:
	next_scene.clear()
	
	var speaker : Dictionary = scene.get("speaker")
	speaker_name = speaker.get("name")
	speaker_emotion = speaker.get("emotion")
	speaker_side = speaker.get("side")
	
	scene_dialogue = scene.get("message")
	
	responses.clear()
	var player_responses = scene.get("player_responses")
	if typeof(player_responses) == TYPE_DICTIONARY:
		responses.assign(player_responses)
	
	next_scene.clear()
	var next = scene.get("next_scene")
	if next != "":
		next_scene.assign(current_cutscene.get(scene.get("next_scene")))
	
	EventBus.dialogue_segment_parsed.emit(speaker_name, speaker_emotion, speaker_side, scene_dialogue, responses, next_scene)
	responses.clear()


func _on_dialogue_segment_finished(next_up: Dictionary) -> void:
	if !next_up.is_empty():
		dialog_builder(next_up)
