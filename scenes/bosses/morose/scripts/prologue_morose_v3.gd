class_name PrologueBoss
extends CharacterBody2D


signal dies
signal action_completed

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

enum Directions {
	LEFT,
	RIGHT,
}

enum Actions {
	CHARGE,
	SLASH,
}

@export var left_edge : Marker2D
@export var right_edge : Marker2D
@export var target : Node2D
@export var talking := true

var combat_state := States.IDLE
var movement_state := States.MOVING
var facing_direction := Directions.LEFT
var target_direction := Directions.LEFT
var charge_speed : int = 1000
var slash_speed : int = 200
var state_machine : AnimationNodeStateMachinePlayback
var left_facing_animations : AnimationNodeStateMachinePlayback
var right_facing_animations : AnimationNodeStateMachinePlayback
var attack_patterns = [[Actions.SLASH, Actions.SLASH, Actions.CHARGE], [Actions.CHARGE, Actions.CHARGE, Actions.SLASH], [Actions.SLASH, Actions.SLASH, Actions.SLASH]]
var attack: Array
var action_ready := false
var cooldown = 2

@onready var boss := $BossPivot/BossSprite
@onready var sword := $BossSword
@onready var hurt_particles := $BossPivot/BossSprite/HurtParticles
@onready var hurt_particles_process_mat : ParticleProcessMaterial = $BossPivot/BossSprite/HurtParticles.get("process_material")
@onready var death_explosion := $BossPivot/BossSprite/Explode
@onready var death_explosion_process_mat : ParticleProcessMaterial = $BossPivot/BossSprite/Explode.get("process_material")
@onready var anim_manager := $AnimationManager
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2


func _ready() -> void:
	state_machine = anim_manager.get("parameters/playback")
	left_facing_animations = anim_manager.get("parameters/facing_left/playback")
	right_facing_animations = anim_manager.get("parameters/facing_right/playback")
	velocity = Vector2(0, gravity)
	attack = attack_patterns.pick_random()
	attack = attack.duplicate()


func _physics_process(_delta: float) -> void:
	if not talking:
		target_direction = Directions.LEFT if (target.position.x <= position.x) else Directions.RIGHT
		_update_side()
		
		if action_ready:
			action_ready = false
			prepare()
	
	move_and_slide()


func prepare() -> void:
	if attack.size() == 0:
		attack = attack_patterns.pick_random()
		attack = attack.duplicate()
		print("Cooldown: ", cooldown)
		await get_tree().create_timer(cooldown).timeout
		
	var action = attack.pop_front() as Actions
	
	if target_direction != facing_direction:
		_turn()
		await action_completed
	
	match action:
		Actions.SLASH:
			slash()
		Actions.CHARGE:
			charge()
		_:
			print("Once again... HOW???")
			action_ready = true


func _update_side() -> void:
	var direction_to_target = target_direction as int
	direction_to_target = (direction_to_target * 2) - 1
	hurt_particles_process_mat.emission_shape_offset.x = -20 * direction_to_target
	hurt_particles_process_mat.direction.x = -1 * direction_to_target
	death_explosion_process_mat.emission_shape_offset.x = -20 * direction_to_target
	death_explosion_process_mat.direction.x = -1 * direction_to_target


func _move(choice:int) -> void:
	var speed = charge_speed if choice else slash_speed
	if (facing_direction == Directions.LEFT):
		velocity = Vector2(-1 * speed, gravity)
	elif (facing_direction == Directions.RIGHT):
		velocity = Vector2(speed, gravity)
	else:
		print("How did you manage this?")


func _halt() -> void:
	velocity = Vector2(0, gravity)


func charge() -> void:
	if facing_direction == Directions.LEFT:
		left_facing_animations.travel("charge_left")
		await action_completed
	elif facing_direction == Directions.RIGHT:
		right_facing_animations.travel("charge_right")
		await action_completed
	action_ready = true


func slash() -> void:
	if facing_direction == Directions.LEFT:
		left_facing_animations.travel("slash_left")
		await action_completed
	elif facing_direction == Directions.RIGHT:
		right_facing_animations.travel("slash_right")
		await action_completed
	action_ready = true


func _turn() -> void:
	if facing_direction == Directions.RIGHT:
		state_machine.travel("facing_left")
		await action_completed
		facing_direction = Directions.LEFT
	elif facing_direction == Directions.LEFT:
		state_machine.travel("facing_right")
		await action_completed
		facing_direction = Directions.RIGHT
	else:
		print("cry")
	
	action_completed.emit()


func _turn_around() -> void:
	$BossPivot/BossSprite.flip_h = !$BossPivot/BossSprite.flip_h


func _on_health_health_depleted() -> void:
	$BossSword/Hitbox.monitoring = false
	$Hitbox.monitoring = false
	anim_manager.active = false
	sword.visible = false
	boss.use_parent_material = true
	boss.self_modulate = Color(0,0,0,0)
	$BossPivot/BossSprite/Explode.restart()
	await $BossPivot/BossSprite/Explode.finished
	dies.emit()
	queue_free()


func _on_health_health_changed(diff: int) -> void:
	if (sign(diff) == -1.0):
		cooldown = 2 * ($Health.health * 1.0 / $Health.max_health)
		hurt_particles.amount_ratio = ($Health.max_health - $Health.health) * 1.0 / $Health.max_health
		hurt_particles.restart()


func _action_completed() -> void:
	action_completed.emit()
