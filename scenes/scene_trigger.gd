extends Area2D

signal triggered

@export var path: String


func _on_body_entered(_body) -> void:
	triggered.emit()
	get_tree().call_deferred("change_scene_to_file", path)
