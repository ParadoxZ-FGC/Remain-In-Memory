extends Node

@export var scene_to_load: String


func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file(scene_to_load)

func _process(delta: float) -> void:
	pass
