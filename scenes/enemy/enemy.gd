extends RigidBody2D


signal state_changed

enum States {
	INACTIVE, 
	DEACTIVATING, 
	READY, 
	STANDBY, 
	FIRING, 
	DYING
}

@export var boom: AudioStreamPlayer2D
@export var projectile_speed: int = 500
@export var fire_recovery_duration: int = 5
@export var lose_focus_timer: int = 5
@export_range(-1, 1, 2) var facing : int = -1

var is_dead : bool = false
var current_state : States
var target : Node2D
var to_deactive := true
var to_activate := false
var can_deactivate := false

@onready var cannonball_loaded := $Cannonball
@onready var hurt_particles := $HurtParticles
@onready var hurt_particles_process_mat = $HurtParticles.get("process_material")


func _ready() -> void:
	if EnemyManager.persistance.has(get_path()):
		queue_free()
	#var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	#$AnimatedSprite2D.play(mob_types[randi() % mob_types.size()])
	current_state = States.INACTIVE
	$AnimatedMobSprite.play("asleep")
	if facing == 1:
		$AnimatedMobSprite.flip_h = true
		cannonball_loaded.flipped = true
		cannonball_loaded.position = Vector2(21.0, -13)
		hurt_particles_process_mat.direction.x = -1


func _physics_process(_delta: float) -> void:
	if current_state == States.INACTIVE and to_activate:
		activate()
		
	elif current_state != States.INACTIVE and current_state != States.FIRING and can_deactivate:
		target = null
		deactivate()
	
	elif target != null:
		if is_instance_valid(cannonball_loaded):
			if (target.position.x - position.x) > 0:
				facing = 1
				$AnimatedMobSprite.flip_h = true
				cannonball_loaded.flipped = true
				cannonball_loaded.position = Vector2(21.0, -13)
				hurt_particles_process_mat.direction.x = -1
			else:
				facing = -1
				$AnimatedMobSprite.flip_h = false
				cannonball_loaded.flipped = false
				cannonball_loaded.position = Vector2(-21.0, -13)
				hurt_particles_process_mat.direction.x = 1
		
		if (current_state == States.READY):
			#print("FIRE!!")
			current_state = States.FIRING
			state_changed.emit()
			fire()


func fire() -> void:
	var anim = $AnimatedMobSprite
	await anim.animation_looped
	anim.play("shoot")
	
	var cannonball_to_fire = cannonball_loaded.duplicate()
	add_child(cannonball_to_fire)
	cannonball_to_fire.fire(projectile_speed, facing)
	
	await $AnimatedMobSprite.animation_finished
	$AnimatedMobSprite.play("standby")
	
	if current_state == States.FIRING:
		current_state = States.STANDBY
		state_changed.emit()
	var timer = get_tree().create_timer(fire_recovery_duration)
	await timer.timeout
	if current_state == States.STANDBY:
		current_state = States.READY
		state_changed.emit()


func activate() -> void:
	to_activate = false
	$AnimatedMobSprite.stop()
	$AnimatedMobSprite.play("wake")
	await $AnimatedMobSprite.animation_finished
	$AnimatedMobSprite.play("standby")
	current_state = States.READY
	state_changed.emit()


func deactivate() -> void:
	current_state = States.DEACTIVATING
	can_deactivate = false
	$AnimatedMobSprite.stop()
	$AnimatedMobSprite.play_backwards("wake")
	await $AnimatedMobSprite.animation_finished
	$AnimatedMobSprite.play("asleep")
	current_state = States.INACTIVE
	state_changed.emit()


func combat_cooldown() -> void:
	var timer := get_tree().create_timer(lose_focus_timer, false)
	await timer.timeout
	if (to_deactive):
		can_deactivate = true


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_health_health_depleted() -> void:
	current_state = States.DYING
	$Hitbox.disable()
	state_changed.emit()
	var anim = $AnimatedMobSprite
	anim.stop()
	#boom.play()
	anim.offset = Vector2(0, -8)
	anim.sprite_frames.set_animation_loop("die", false)
	anim.play("die")
	await anim.animation_finished
	#boom.stop()
	EnemyManager.persistance.set(get_path(), ["nerd"])
	queue_free()


func _on_detectionbox_body_entered(body: Node2D) -> void:
	#print("Detection Entered")
	to_deactive = false
	if current_state == States.DEACTIVATING:
		await state_changed
	if current_state == States.INACTIVE and not to_deactive:
		#print("Detected")
		target = body
		to_activate = true


func _on_detectionbox_body_exited(_body: Node2D) -> void:
	#print("Dectection Exited")
	to_deactive = true
	combat_cooldown()
	
	
func print_state() -> void:
	pass
	#print(States.find_key(current_state))


func _on_health_health_changed(diff: int) -> void:
	if (sign(diff) == -1.0):
		hurt_particles.emitting = true
