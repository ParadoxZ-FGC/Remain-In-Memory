extends Node2D

@export var speed: int = 500
@export var gravity: float = 1

enum codeAimType {Static = 0, Aiming = 1 }
@export_enum("Static", "Aiming") var aimType: int

var directionV : Vector2
var timer : SceneTreeTimer
var flipped := false
var directionRay: RayCast2D
var rayFlipped: bool = false
var rdy: bool = false
@onready var attack: Node2D = get_parent().get_parent().get_parent()


func _ready() -> void:
	directionRay = $DirectionRay
	rdy = true

func _process(_delta: float) -> void:
	if rdy:
		if ($Projectile/Sprite2D.flip_h != flipped):
			$Projectile/Sprite2D.flip_h = flipped
		if (aimType == codeAimType.Static and rayFlipped != flipped):
			rayFlipped = true
			directionRay.target_position *= Vector2(-1, 1)
			position *= Vector2(-1, 0)

func fire() -> void:
	flipped = attack.facing
	if flipped:
		directionRay.target_position.x = abs(directionRay.target_position.x)
	else:
		directionRay.target_position.x = abs(directionRay.target_position.x) * -1
	
	var projectileToFire = $Projectile.duplicate()
	add_child(projectileToFire)
	projectileToFire.position = position
	directionV = Vector2(directionRay.target_position.x, directionRay.target_position.y).normalized()
	projectileToFire.directionVector = directionV
	projectileToFire.speed = speed
	projectileToFire.grav = gravity
	projectileToFire.move()
	projectileToFire.get_node("Hitbox").activate(-1)
