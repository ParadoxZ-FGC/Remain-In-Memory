extends CharacterBody2D

signal facing_changed(facing_right: bool) 

@export var upper = Vector2(0, 0)
@export var lower = Vector2(2500, 1080)
@export var speed = 1000
@export var jump_speed = 900
@export var max_walk_speed = 300
@export var max_run_speed = 500
@export var stop_force = 8000
@export var stone: AudioStreamPlayer2D 
@export var facingRight: bool = true

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2
@onready var health : Health = $Health

var scene_transitions
var facing_right = true


func _ready():
	connect("facing_changed", Callable($AnimatedWeaponSprite, "_on_facing_changed"))
	health.max_health = PlayerData.maximum_health
	health.health = PlayerData.current_health


func set_facing(facingAxis: float) -> void: 
	if (facingAxis > 0):
		#print("right")  
		if (!facing_right): 
			facing_right = true 
			emit_signal("facing_changed", facing_right)
	elif (facingAxis < 0):
		#print("left")
		if (facing_right): 
			facing_right = false 
			emit_signal("facing_changed", facing_right)


func _physics_process(delta):
	var facingAxis = Input.get_axis("move_left", "move_right")
	set_facing(facingAxis)
	var walk = speed * facingAxis
	if abs(walk) < speed * 0.2:
		velocity.x = move_toward(velocity.x, 0, stop_force * delta)
	else:
		velocity.x += walk * delta
	velocity.x = clamp(velocity.x, -max_run_speed, max_run_speed) if Input.is_action_pressed("run") else clamp(velocity.x, -max_walk_speed, max_walk_speed)
	$AnimatedPlayerSprite.scale = Vector2(0.2, 0.1) if Input.is_action_pressed("crouch_look_down") else Vector2(0.2, 0.2)
	
	# This shrinks the player so they can go under shorter areas, whoever, it gets stuck on the floor
	#$CollisionShape2D.scale = Vector2(1, 0.5) if Input.is_action_pressed("crouch_look_down") else Vector2(1, 1)
	#$HurtBox/CollisionShape2D.scale = Vector2(1, 0.5) if Input.is_action_pressed("crouch_look_down") else Vector2(1, 1)
	 
	
	velocity.y += gravity * delta
	
	move_and_slide()
	position = position.clamp(upper, lower)
	
	if velocity.length() > 0:
		if is_on_floor(): 
			if !stone.playing:
				stone.play()
		else: 
			stone.stop()
		$AnimatedPlayerSprite.play()
	else: 
		stone.stop()
		$AnimatedPlayerSprite.stop()
	
	if velocity.x != 0:
		$AnimatedPlayerSprite.animation = "walk"
		$AnimatedPlayerSprite.flip_v = false
		$AnimatedPlayerSprite.flip_h = velocity.x < 0
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_speed


func _on_health_health_depleted() -> void:
	get_tree().quit()


func on_scene_transitions() -> void:
	PlayerData.maximum_health = health.max_health
	PlayerData.current_health = health.health


func connect_triggers():
	if scene_transitions != null:
		for trigger in scene_transitions.get_children():
			trigger.triggered.connect(on_scene_transitions)
