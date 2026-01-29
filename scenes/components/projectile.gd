extends Node2D

var directionVector: Vector2
var moving: bool = false

func _ready():
	visible = false

func _physics_process(delta: float) -> void:
	if moving:
		self.global_position += directionVector * delta

func move():
	moving = true
	visible = true
	$Hitbox.activate(-1)
	var timer = get_tree().create_timer(5, false, true, false)
	timer.timeout.connect(_end_of_life)

func _end_of_life() -> void:
	queue_free()

func _on_hitbox_impacted() -> void:
	_end_of_life()
