extends Node2D

@export var speed: int = 500

enum codeAimType {Static = 0, Aiming = 1 }
@export_enum("Static", "Aiming") var aimType: int

var directionV : Vector2
var timer : SceneTreeTimer
var flipped := false
var directionRay: RayCast2D
var rayFlipped: bool = false
var rdy: bool = false


func _ready() -> void:
	directionRay = $DirectionRay
	rdy = true

func flip():
	flipped = !flipped

func _process(_delta: float) -> void:
	if rdy:
		if ($Projectile/Sprite2D.flip_h != flipped):
			$Projectile/Sprite2D.flip_h = flipped
		if (aimType == codeAimType.Static and rayFlipped != flipped):
			rayFlipped = true
			directionRay.target_position *= Vector2(-1, 0)
			position *= Vector2(-1, 0)

func fire() -> void:
	var projectileToFire = $Projectile.duplicate()
	add_child(projectileToFire)
	directionV = Vector2(speed * directionRay.target_position.x, 0)
	projectileToFire.directionVector = directionV
	projectileToFire.move()
	projectileToFire.get_node("Hitbox").activate(-1)
