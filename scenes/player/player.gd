extends CharacterBody2D

@export var upper = Vector2(0, 0)
@export var lower = Vector2(2500, 1080)
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2
@export var speed = 1000
@export var jump_speed = 900
@export var max_walk_speed = 300
@export var max_run_speed = 500
@export var stop_force = 8000
@export var stone: AudioStreamPlayer2D 
@export var facingRight: bool = true

signal facing_changed(facing_right: bool) 
var facing_right = true

func _ready(): 
	connect("facing_changed", Callable($AnimatedSprite2D2, "_on_facing_changed"))

func set_facing() -> void: 
	if(Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right")): 
		#print("nuh uh")
		pass
	elif (Input.is_action_pressed("move_right")):
		#print("right")  
		if (!facing_right): 
			facing_right = true 
			emit_signal("facing_changed", facing_right)
	elif (Input.is_action_pressed("move_left")):
		#print("left")
		if (facing_right): 
			facing_right = false 
			emit_signal("facing_changed", facing_right)

func _physics_process(delta):
	set_facing()
	var walk = speed * (Input.get_axis("move_left", "move_right"))
	if abs(walk) < speed * 0.2:
		velocity.x = move_toward(velocity.x, 0, stop_force * delta)
	else:
		velocity.x += walk * delta
	velocity.x = clamp(velocity.x, -max_run_speed, max_run_speed) if Input.is_action_pressed("run") else clamp(velocity.x, -max_walk_speed, max_walk_speed)
	$AnimatedSprite2D.scale = Vector2(0.2, 0.1) if Input.is_action_pressed("crouch_look_down") else Vector2(0.2, 0.2)
	 
	
	velocity.y += gravity * delta
	
	move_and_slide()
	position = position.clamp(upper, lower)
	
	if velocity.length() > 0:
		if is_on_floor(): 
			if !stone.playing:
				stone.play()
		else: 
			stone.stop()
		$AnimatedSprite2D.play()
	else: 
		stone.stop()
		$AnimatedSprite2D.stop()
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_speed
