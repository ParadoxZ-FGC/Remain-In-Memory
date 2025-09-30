extends CharacterBody2D


enum States {
	IDLE, 
	SWINGING, 
	STOPPED, 
	MOVING,
}

@export var left_edge : Marker2D
@export var right_edge : Marker2D
@export var target : Node2D

var combat_state := States.IDLE
var movement_state := States.MOVING
var direction : int = -1
var walking_speed : int = 200
var can_turn := true
var can_pause := true

@onready var sword := $BossSword
@onready var hurt_particles := $BossSprite/HurtParticles
@onready var hurt_particles_process_mat = $BossSprite/HurtParticles.get("process_material")
@onready var anim_player := $AnimationPlayer
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2


func _physics_process(delta: float) -> void:
	if can_pause and movement_state == States.MOVING:
		if (randi_range(0, 2) == 0):
			_pause_walk()
		else:
			_pause_cooldown()
	
	if (position.x - target.position.x > 0):
		hurt_particles_process_mat.emission_shape_offset.x = 20
		hurt_particles_process_mat.direction.x = 1
	else:
		hurt_particles_process_mat.emission_shape_offset.x = -20
		hurt_particles_process_mat.direction.x = -1
	
	if movement_state == States.MOVING:
		velocity.x = walking_speed * direction
	
	else:
		velocity.x = 0
	
	velocity.y += gravity * delta
	move_and_slide()
	
	if can_turn and (position.x <= left_edge.position.x or position.x >= right_edge.position.x):
		_turn_around()
	
	if combat_state == States.IDLE and movement_state == States.MOVING:
		_attack()


func _attack() -> void:
	combat_state = States.SWINGING
	var choice = randi_range(0,1)
	if direction == -1:
		if choice == 1:
			anim_player.play("swipe_front_left")
		else:
			anim_player.play("stab_front_left")
			
	else:
		if choice == 1:
			anim_player.play("swipe_front_right")
		else:
			anim_player.play("stab_front_right")
		
	await anim_player.animation_finished
	_rest()
	
	var timer = get_tree().create_timer(randi_range(1, 3), false, false)
	await timer.timeout
	combat_state = States.IDLE


func _rest() -> void:
	if direction == -1:
		anim_player.play("rest_left")
	
	else:
		anim_player.play("rest_right")


func _turn_around() -> void:
	can_turn = false
	movement_state = States.STOPPED
	if anim_player.is_playing():
		await anim_player.animation_finished
	direction *= -1
	$BossSprite.flip_h = not $BossSprite.flip_h
	$BossSword/SwordSprite.flip_h = not $BossSword/SwordSprite.flip_h
	_rest()
	movement_state = States.MOVING
	var timer = get_tree().create_timer(1, false)
	await timer.timeout
	can_turn = true


func _pause_walk() -> void:
	_pause_cooldown()
	movement_state = States.STOPPED
	
	var timer = get_tree().create_timer(1, false)
	await timer.timeout
	_turn_around()


func _pause_cooldown() -> void:
	can_pause = false
	var timer = get_tree().create_timer(5, false)
	await timer.timeout
	can_pause = true


func _on_health_health_depleted() -> void:
	queue_free()


func _on_health_health_changed(diff: int) -> void:
	if (sign(diff) == -1.0):
		hurt_particles.emitting = true
