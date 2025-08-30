extends Area2D

@export var path: String

func _on_body_entered(_body) -> void:
	print(type_string(typeof(_body)))
	get_tree().call_deferred("change_scene_to_file", path)
