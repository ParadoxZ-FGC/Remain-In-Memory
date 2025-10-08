class_name Interactable #INFO Currently only supports dialogue interactions, but I figured I'd make the full class for the future
extends Node2D

@export var enabled: bool = true: set = set_enabled, get = get_enabled
@export var file : String

func set_enabled(x: bool):
	enabled = x
	set_deferred("monitorable", x)

func get_enabled():
	return enabled
	
func _ready():
	set_enabled(enabled)

func _on_area_2d_area_entered(_area: Area2D) -> void:
	EventBus.emit_signal("interact", file)

func _on_area_2d_area_exited(_area: Area2D) -> void:
	EventBus.emit_signal("stopInteract")
