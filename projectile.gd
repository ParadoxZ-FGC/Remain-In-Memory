extends Node2D

var directionVector: Vector2
var moving: bool = false
var grav: float = 0
var velX: float = 0
var velY: float = 0
var speed: float = 0

func _ready():
	visible = false

func _physics_process(delta: float) -> void:
	if moving:
		global_position.x += velX * delta
		if grav:
			velY += grav
		global_position.y += velY * delta

func move():
	moving = true
	visible = true
	velX = directionVector.x * speed
	velY = directionVector.y * speed
	$Hitbox.activate(-1)

func _end_of_life() -> void:
	moving = false
	queue_free()

func _on_hitbox_impacted() -> void:
	_end_of_life()

func _on_health_health_depleted() -> void:
	_end_of_life()
