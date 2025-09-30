extends CharacterBody2D


signal updated

@export var upper = Vector2(0, 0)
@export var lower = Vector2(2500, 1080)
@export var speed = 1000
@export var jump_speed = 800
@export var coyote: float = 0.03
@export var max_walk_speed = 300
@export var max_run_speed = 500
@export var stop_force = 8000
@export var drag_force = 500
@export var stone: AudioStreamPlayer2D

var coyoteTimer: float = 0
var movementDirection: bool = true #rightward = true
var movementIntentionDirection: bool = true
var movementIntention: float

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2
@onready var health : Health = $Health

var scene_transitions


func _ready():
	health.max_health = PlayerData.maximum_health
	health.health = PlayerData.current_health

func _physics_process(delta):
	movementIntention = Input.get_axis("move_left", "move_right")
	movementDirection = true if velocity.x > 0 else false
	movementIntentionDirection = true if movementIntention >= 0 else false
	var walk = speed * movementIntention
	if abs(walk) < speed * 0.2:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, stop_force * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, drag_force * delta)
	else:
		if movementIntentionDirection != movementDirection:
			velocity.x -= velocity.x / 8 * 7
			
	velocity.x += walk * delta
	
	velocity.x = clamp(velocity.x, -max_run_speed, max_run_speed) if Input.is_action_pressed("run") else clamp(velocity.x, -max_walk_speed, max_walk_speed)
	 
	
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
		if $Sword.attacking == false:
			$Sword.scale = Vector2(1, 1) if velocity.x > 0 else Vector2(-1, 1)
		
	if is_on_floor():
		coyoteTimer = 0
	else:
		coyoteTimer += delta
		clamp(coyoteTimer, 0, coyote)
	
	if (is_on_floor() or coyoteTimer < coyote) and Input.is_action_just_pressed("jump"):
		jump()
	
	if not is_on_floor() and Input.is_action_just_released("jump"):
		jump_stop()
	
	if Input.is_action_just_pressed("attack"):
		$Sword.attack()

func jump():
	velocity.y = -jump_speed

func jump_stop():
	if velocity.y < -100:
		velocity.y = -100

func _unhandled_key_input(event: InputEvent) -> void:
	if (event.is_action_pressed("crouch_look_down")):
		$AnimatedPlayerSprite.scale = Vector2(0.2, 0.1)
		$PlayerCollisionShape.scale = Vector2(1, 0.5)
		$Hurtbox/CollisionShape2D.scale = Vector2(1, 0.5)
		
	elif (event.is_action_released("crouch_look_down")):
		$AnimatedPlayerSprite.scale = Vector2(0.2, 0.2)
		$PlayerCollisionShape.scale = Vector2(1, 1)
		$Hurtbox/CollisionShape2D.scale = Vector2(1, 1)


func _on_health_health_depleted() -> void:
	get_tree().quit()


func on_scene_transitions() -> void:
	PlayerData.maximum_health = health.max_health
	PlayerData.current_health = health.health
	updated.emit()


func connect_triggers():
	var triggers = get_tree().get_nodes_in_group("scene_transitions")
	for trigger in triggers:
		trigger.triggered.connect(on_scene_transitions)
