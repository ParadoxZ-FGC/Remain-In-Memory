extends Area2D


signal triggered

@export var path: String


func _ready() -> void:
	add_to_group("scene_transitions")


func _on_body_entered(_body) -> void:
	triggered.emit()
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().call_deferred("change_scene_to_file", path)
