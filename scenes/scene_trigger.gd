extends Area2D

@export var path: String

func _on_body_entered(_body) -> void:
	get_tree().call_deferred("change_scene_to_file", path)
