extends Node2D


enum States {LOADED, FIRED}

var current_state : States = States.LOADED
var directionVector : Vector2
var timer : SceneTreeTimer
var flipped := false


func _ready() -> void:
	visible = false


func _process(_delta: float) -> void:
	if ($Sprite2D.flip_h != flipped):
		$Sprite2D.flip_h = flipped


func _physics_process(delta: float) -> void:
	if (current_state == States.FIRED):
		position += directionVector * delta
		$Hitbox.activate(-1)


func fire(speed : int, direction : int) -> void:
	timer = get_tree().create_timer(5, false, true, false)
	timer.timeout.connect(_end_of_life)
	directionVector = Vector2(speed * direction, 0)
	visible = true
	current_state = States.FIRED
	$Hitbox.enable()


func _end_of_life() -> void:
	queue_free()


func _on_hitbox_impacted() -> void:
	_end_of_life()
