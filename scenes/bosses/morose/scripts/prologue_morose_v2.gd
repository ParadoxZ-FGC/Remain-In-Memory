class_name OldPrologueBoss
extends CharacterBody2D


signal dies

enum States {
	IDLE, 
	SWINGING, 
	STOPPED, 
	MOVING,
}

enum Sprites {
	BODY,
	SWORD,
	BOTH,
}

@export var left_edge : Marker2D
@export var right_edge : Marker2D
@export var target : Node2D
@export var talking := true

var combat_state := States.IDLE
var movement_state := States.MOVING
var facing_direction : int = -1
var walking_speed : int = 100
var can_turn := true
var can_pause := true
var in_stab_range := false
var in_slash_range := false
var pursue := false
var attacking := false
var turning := false
var state_machine : AnimationNodeStateMachinePlayback
var left_facing_animations : AnimationNodeStateMachinePlayback
var right_facing_animations : AnimationNodeStateMachinePlayback

@onready var boss := $BossSprite
@onready var sword := $BossSword
@onready var hurt_particles := $BossSprite/HurtParticles
@onready var hurt_particles_process_mat : ParticleProcessMaterial = $BossSprite/HurtParticles.get("process_material")
@onready var death_explosion := $BossSprite/Explode
@onready var death_explosion_process_mat : ParticleProcessMaterial = $BossSprite/Explode.get("process_material")
@onready var attack_timer := $AttackTimer
@onready var anim_manager := $AnimationManger
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2


func _ready() -> void:
	state_machine = anim_manager.get("parameters/playback")
	left_facing_animations = anim_manager.get("parameters/facing_left/playback")
	right_facing_animations = anim_manager.get("parameters/facing_right/playback")
	attack_timer.one_shot = true


func _physics_process(_delta: float) -> void:
	if not talking:
		var direction_to_target = 1 if (target.position.x - position.x >= 0) else -1
		hurt_particles_process_mat.emission_shape_offset.x = -20 * direction_to_target
		hurt_particles_process_mat.direction.x = -1 * direction_to_target
		death_explosion_process_mat.emission_shape_offset.x = -20 * direction_to_target
		death_explosion_process_mat.direction.x = -1 * direction_to_target
		
		if direction_to_target != facing_direction and not turning and not attacking:
			print("HE'S BEHIND YOU")
			turning = true
			_turn()
		
		if attacking or turning:
			pursue = false
		elif not in_stab_range:
			pursue = true
		elif in_stab_range and attack_timer.is_stopped() and not attacking:
			attack_timer.start()
		elif in_slash_range:
			pursue = false
	
	if pursue:
		velocity = Vector2(facing_direction * walking_speed, gravity)
	else:
		velocity = Vector2(0, gravity)
	
	move_and_slide()


func _attack(direction:int) -> void:
	if turning:
		return
	elif in_slash_range:
		slash(direction)
	elif in_stab_range:
		stab(direction)


func stab(direction:int) -> void:
	print("stab yes")
	attacking = true
	if direction == -1:
		left_facing_animations.travel("stab_left")
		await left_facing_animations.state_finished # Wait for idle animation to finish
		await left_facing_animations.state_finished # Wait for attack to finish
	elif direction == 1:
		right_facing_animations.travel("stab_right")
		await right_facing_animations.state_finished # Wait for idle animation to finish
		await right_facing_animations.state_finished # Wait for attack to finish
	attacking = false


func slash(direction:int) -> void:
	print("slash yes")
	attacking = true
	if direction == -1:
		left_facing_animations.travel("slash_left")
		await left_facing_animations.state_finished # Wait for idle animation to finish
		await left_facing_animations.state_finished # Wait for attack to finish
	elif direction == 1:
		right_facing_animations.travel("slash_right")
		await right_facing_animations.state_finished # Wait for idle animation to finish
		await right_facing_animations.state_finished # Wait for attack to finish
	attacking = false


func _turn() -> void:
	print("turning")
	if facing_direction == 1:
		state_machine.travel("facing_left")
		await state_machine.state_finished # No crossfade, no need for two awaits
		facing_direction = -1
	elif facing_direction == -1:
		state_machine.travel("facing_right")
		await state_machine.state_finished # No crossfade, no need for two awaits
		facing_direction = 1
	else:
		print("cry")
	
	turning = false


func _turn_around() -> void:
	$BossSprite.flip_h = !$BossSprite.flip_h


func _on_health_health_depleted() -> void:
	$BossSword/Hitbox.monitoring = false
	$Hitbox.monitoring = false
	anim_manager.active = false
	sword.visible = false
	boss.use_parent_material = true
	boss.self_modulate = Color(0,0,0,0)
	$BossSprite/Explode.restart()
	await $BossSprite/Explode.finished
	dies.emit()
	queue_free()


func _on_health_health_changed(diff: int) -> void:
	if (sign(diff) == -1.0):
		hurt_particles.amount_ratio = ($Health.max_health - $Health.health) * 1.0 / $Health.max_health
		hurt_particles.restart()


func _on_stab_range_body_entered(_body: Node2D) -> void:
	in_stab_range = true


func _on_stab_range_body_exited(_body: Node2D) -> void:
	in_stab_range = false


func _on_slash_range_body_entered(_body: Node2D) -> void:
	in_slash_range = true


func _on_slash_range_body_exited(_body: Node2D) -> void:
	in_slash_range = false


func _on_attack_timer_timeout() -> void:
	_attack(facing_direction)
