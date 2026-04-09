extends Node2D
@onready var layers := {
	$Layer0: 0.0, 
	$Layer1: 0.005, 
	$Layer2: 0.01, 
	$Layer3: 0.02, 
	$Layer4: 0.04, 
	$Layer5: 0.08, 
	$Layer6: 0.16, 
	$Layer7: 0.0
	}

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		for n in layers:
			n.position = toParallaxPos(event.position, layers[n])

func toParallaxPos(mouse: Vector2, f: float) -> Vector2:
	var vect : Vector2 = (mouse - Vector2(960,540)) * f
	return vect
