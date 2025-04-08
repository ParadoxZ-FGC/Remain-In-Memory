extends Area2D

@export var path: String

func _on_body_entered(body: PhysicsBody2D) -> void:
	get_tree().change_scene_to_file(path)
