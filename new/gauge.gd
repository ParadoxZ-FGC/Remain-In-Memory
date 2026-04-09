extends Node2D


@export_range(0, 270, 0.1) var needle_angle : float = 0 : set = set_needle_angle

var needle_tween : Tween
var animate := false

@onready var needle := $Offset/Needle
@onready var player := $Offset/AnimationPlayer


func _ready() -> void:
	needle_angle = PlayerData.current_gauge_angle
	animate = true

func enable() -> void:
	visible = true


func disable() -> void:
	visible = false


func set_needle_angle(degrees: float):
	needle_angle = degrees
	if needle_tween != null:
		needle_tween.kill()
		
	if animate == false:
		needle.rotation_degrees = needle_angle
	else:
		needle_tween = create_tween()
		needle_tween.tween_property(needle, "rotation_degrees", needle_angle, 0.2).from_current()
		await needle_tween.finished
	_determine_pressure()


func _determine_pressure() -> void:
	if needle_angle >= 240:
		player.play("Shake")
	elif needle_angle >= 180:
		player.play("Wiggle")
	else:
		player.play("Still")
