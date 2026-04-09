extends CharacterBody2D
class_name PlayerCharacter


signal updated

enum dialogueTypes {None, Chatting, Talking} #TODO I have no idea if we want "passive conversation", like npcs saying things without player input, that's what Chatting is for, just in case
enum player_states {User_Controlled, System_Controlled}
enum weaponSelect {Sword, Glaive}

@export var upper = Vector2(0, 0)
@export var lower = Vector2(2500, 1080)
@export var speed = 1000
@export var jump_speed = 800
@export var jumped : int = 0
@export var coyote: float = 0.03
@export var max_walk_speed = 300
@export var max_run_speed = 500 #default 500
@export var max_dash_speed = 1000
@export var dash_speed = 1000
@export var dash_duration = 0.075
@export var dashCoolDownLength: float = 1.5
@export var wavedashGroundForgiveness: float = 0.25
@export var wavedashValidInputDuration: float = 1.0
@export var wavedashLength: float = 1.0
@export var stop_force = 8000
@export var drag_force = 500
@export var momentum_loss = 1500
@export var walking_sfx: AudioStreamPlayer2D
@export var swing_sfx: AudioStreamPlayer2D
@export var knockbackTime: float = 0.05 #Determines how long the player is in knockback, @TODO might move to the knockback function itself
var knockedback:bool=false  # if TRUE: the player has been knocked back and hasn't touched the ground yet
@export var to_scene_on_death := true
@export var death_scene : String

var inKnockback: bool = false #Whether or not the player is in knockback, limits movement.
var coyoteTimer: float = 0
var movementDirection: bool = true #rightward = true
var movementIntentionDirection: bool = true
var movementIntention: float
enum dashState {NOTDASHING = 0, DASHING = 1, AIRDASHING = 2, WAVEDASHING = 3}
var dashing: bool = false
var wavedashing: int = dashState.NOTDASHING
var wavedashForgivenessTimer: float = 0
var dashCoolDown: float = 3
var scene_transitions
var currentDialogue : dialogueTypes = dialogueTypes.None
var current_player_state : player_states = player_states.User_Controlled
var interactable : bool = false #Is there something to interact with
var interact_scene : String #INFO Interactable currently only handles dialogue, so this would be the file one reads from
var currentWeapon: weaponSelect = weaponSelect.Sword
var delayedFlip: Node2D #Used in cases where the player inputs an attack and then changes facing direction. Prevents flicking the weapon back and forth.
var last_position : Vector2

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2
@onready var health : Health = $Health
@onready var dialogueHandler = $DialogueHandler
@onready var player_sprite := $player_sprite
@onready var hearts := $GUILayer/GUI/HealthDisplay
@onready var gauge := $GUILayer/GUI/Gauge
@onready var steam_jump := $SteamJump
@onready var interaction := $InteractDisplay
@onready var dashTimer = $DashTimer
@onready var lfc := $HazardDetect/LeftFloorCheck
@onready var rfc := $HazardDetect/RightFloorCheck
@onready var lhc := $HazardDetect/LeftHazardCheck
@onready var rhc := $HazardDetect/RightHazardCheck


func _ready():
	health.max_health = PlayerData.maximum_health
	health.health = PlayerData.current_health
	gauge.enable()
	EventBus.start_dialogue.connect(_on_dialogue_start)
	EventBus.finish_dialogue.connect(_text_over)
	EventBus.swap_control_state.connect(_swap_player_control_state)
	EventBus.interactableToggle.connect(interactablePrompt)
	#EventBus.connect("interaction_available", _on_interactable)
	#EventBus.connect("interaction_unavailable", _off_interactable)
	#EventBus.connect("finish_dialogue", _text_over)
	$player_sprite.play()


func _on_dialogue_start():
	currentDialogue = dialogueTypes.Talking


#func _on_interactable(dialogue_scene): #Signals when overlapping interactable
	#interactable = true
	#interact_scene = dialogue_scene


#func _off_interactable(): #Signals when leaving interactable #BUG/ALERT This will almost definitely cause issues with multiple interactables close enough to eachother to both be overlapped by the player.
	#interactable = false
	#interact_scene = ""


func _text_over(_cutscene:String): #Signals when dialogue file is done
	currentDialogue = dialogueTypes.None


func _physics_process(delta):
	if is_on_floor() and (lfc.get_collider() != null and rfc.get_collider() != null) and (lhc.get_collider() == null and rhc.get_collider() == null):
		last_position = position
	
	if currentDialogue != dialogueTypes.Talking and current_player_state == player_states.User_Controlled: #If player isnt in dialogue do normal player activities
		move(Input.get_axis("move_left", "move_right"), delta) #NOTICE Movement has been move(ment)d to a function
		if Input.is_action_just_pressed("attack"):
			match currentWeapon:
				weaponSelect.Sword:
					$"Sword/1/Hitbox/Hitbox".direction=Vector2(-1 if $player_sprite.flip_h else 1,0)
					$"Sword/1/Hitbox/Hitbox".weight=200
					$Sword.attack()
					
				weaponSelect.Glaive:
					$"Glaive/1/Hitbox/hitbox".direction=Vector2(-1 if $player_sprite.flip_h else 1,0)
					$"Glaive/1/Hitbox/hitbox".weight=200
					$Glaive.attack()
					
		
		if Input.is_action_just_pressed("dash") and dashCoolDown >= dashCoolDownLength:
			dash(Input.get_axis("move_left", "move_right"), Input.get_axis("look_up", "crouch"))
		if dashCoolDown <= dashCoolDownLength:
			dashCoolDown += delta

		if Input.is_action_just_pressed("(TEMP) change_weapon"):
			if currentWeapon < weaponSelect.size() -1:
				currentWeapon = currentWeapon + 1 as weaponSelect
			else:
				currentWeapon = 0 as weaponSelect 
		
		if interactable and Input.is_action_just_pressed("interact"): #If player can interact (INFO w/ dialogue), and they press the button to, disable normal player activies and engage dialogue.
			#[This appears to never be called] print("pressed! #1");
			currentDialogue = dialogueTypes.Talking
			DialogueManager.load_dialogue_scene(interact_scene)
	
	elif currentDialogue == dialogueTypes.Talking: #If player is in dialogue, only allow interact key which advances it.
		if Input.is_action_just_pressed("interact"):
			#[This appears to never be called] print("pressed! #2");
			pass
			#dialogueHandler.readFile()
	
	elif current_player_state == player_states.System_Controlled:
		move(0, delta)
	
	if velocity.x != 0:
		if is_on_floor(): 
			if !walking_sfx.playing:
				walking_sfx.play()
		else: 
			walking_sfx.stop()
		
	else: 
		walking_sfx.stop()
		$player_sprite.animation = "idle"
	
	if velocity.x != 0 and not knockedback and not inKnockback:
		$player_sprite.animation = "walk"
		$player_sprite.flip_v = false
		
		match currentWeapon:
				weaponSelect.Sword:
					if $Sword.attackCooling == false:
						$Sword.scale = Vector2(1, 1) if velocity.x > 0 else Vector2(-1, 1)
					else:
						delayedFlip = $Sword
				weaponSelect.Glaive:
					if $Glaive.attackCooling == false:
						$Glaive.scale = Vector2(1, 1) if velocity.x > 0 else Vector2(-1, 1)
					else:
						delayedFlip = $Glaive
	
	if velocity.x != 0 and Input.is_action_pressed("run"):
		$player_sprite.speed_scale = 2
	else:
		$player_sprite.speed_scale = 1
		
	move_and_slide()
	
	if is_on_floor():
		knockedback=false
	
	if delayedFlip and not delayedFlip.attackCooling:
		delayedFlip.scale = Vector2(-1, 1) if $player_sprite.flip_h else Vector2(1, 1)


func move(movement_vector, delta):
	if(not(knockedback)):
		movementIntention = movement_vector
		movementDirection = true if velocity.x > 0 else false
		movementIntentionDirection = true if movementIntention >= 0 else false
		var walk = speed * movementIntention
		if not dashing:
			if abs(walk) < speed * 0.2:
				if is_on_floor():
					velocity.x = move_toward(velocity.x, 0, stop_force * delta)
				else:
					velocity.x = move_toward(velocity.x, 0, drag_force * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, drag_force * delta)
		else:
			if movementIntentionDirection != movementDirection:
				velocity.x -= velocity.x / 8 * 7
				if wavedashing == dashState.WAVEDASHING:
					wavedashing = dashState.NOTDASHING
		
		velocity.y += gravity * delta

		if Input.is_action_pressed("run") and current_player_state == player_states.User_Controlled:
			if wavedashing == dashState.WAVEDASHING:
				if velocity.x < max_dash_speed and velocity.x > -max_dash_speed:
					velocity.x += walk * delta
				velocity.x = clamp(velocity.x, -max_dash_speed, max_dash_speed)
			else:
				if velocity.x < max_run_speed and velocity.x > -max_run_speed:
					velocity.x += walk * delta
				else:
					if velocity.x > max_run_speed:
						velocity.x = move_toward(velocity.x, max_run_speed, momentum_loss * delta)
					elif velocity.x < -max_run_speed:
						velocity.x = move_toward(velocity.x, -max_run_speed, momentum_loss * delta)
				$player_sprite.flip_h = velocity.x < 0
			elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") and not dashing:
				velocity.x += walk * delta
				velocity.x = clamp(velocity.x, -max_walk_speed, max_walk_speed)
				$player_sprite.flip_h = velocity.x < 0
		else:
			velocity.x = clamp(velocity.x, -max_dash_speed, max_dash_speed)
	
	position = position.clamp(upper, lower)
	velocity.y += gravity * delta

	if is_on_floor():
		coyoteTimer = 0
		if wavedashForgivenessTimer < wavedashGroundForgiveness:
			wavedashForgivenessTimer += delta
		else:
			wavedashing = dashState.NOTDASHING
	else:
		coyoteTimer += delta
		clamp(coyoteTimer, 0, coyote)

func dash(lr, ud):
	if is_on_floor():
		wavedashing = dashState.DASHING
	else:
		wavedashForgivenessTimer = 0
		wavedashing = dashState.AIRDASHING
	dashing = true
	
	dashCoolDown = 0
	dashTimer.start(dash_duration)
	if(abs(ud) == 0):
		velocity.x += lr * dash_speed * 2
	velocity.x += lr * dash_speed
	velocity.y += ud * dash_speed/2

func dash_stop():
	velocity.y = 0
	dashing = false
	if wavedashing == dashState.AIRDASHING:
		await get_tree().create_timer(wavedashValidInputDuration).timeout
		if wavedashing != dashState.WAVEDASHING:
			wavedashing = dashState.NOTDASHING

func jump():
    if jumped == 0:
        jumped += 1
        velocity.y = -jump_speed
    elif jumped == 1 and gauge.needle_angle >= 90:
        jumped += 1
        gauge.needle_angle -= 30
        velocity.y = -jump_speed # * 1.1
        steam_jump.emitting = true
    if wavedashForgivenessTimer < wavedashGroundForgiveness and wavedashing == dashState.AIRDASHING:
        wavedashing = dashState.WAVEDASHING
        await get_tree().create_timer(wavedashLength).timeout
        wavedashing = dashState.NOTDASHING


func jump_stop():
	if velocity.y < -100:
		velocity.y = -100

func _unhandled_input(event: InputEvent) -> void:
	if (current_player_state == player_states.User_Controlled):
		if (event.is_action_pressed("crouch")):
			$player_sprite.scale = Vector2(0.2, 0.1)
			$PlayerCollisionShape.scale = Vector2(1, 0.5)
			$Hurtbox/CollisionShape2D.scale = Vector2(1, 0.5)
			
		elif (event.is_action_released("crouch")):
			$player_sprite.scale = Vector2(0.2, 0.2)
			$PlayerCollisionShape.scale = Vector2(1, 1)
			$Hurtbox/CollisionShape2D.scale = Vector2(1, 1)
		
		if coyoteTimer >= coyote and jumped == 0:
			jumped = 1
		
		if event.is_action_pressed("jump") and not dashing:
			jump()
		
		if not is_on_floor() and event.is_action_released("jump"):
			jump_stop()
		
	else:
		if (event.is_action_released("crouch")):
			$player_sprite.scale = Vector2(0.2, 0.2)
			$PlayerCollisionShape.scale = Vector2(1, 1)
			$Hurtbox/CollisionShape2D.scale = Vector2(1, 1)


func _on_health_health_depleted() -> void:
	if to_scene_on_death:
		var scene = load(death_scene)
		PlayerData.current_health = PlayerData.maximum_health
		get_tree().call_deferred("change_scene_to_packed", scene)
		
	else:
		EventBus.player_dies.emit()


func on_scene_transitions() -> void:
	PlayerData.maximum_health = health.max_health
	PlayerData.current_health = health.health
	PlayerData.current_gauge_angle = gauge.needle_angle
	updated.emit()


func connect_triggers():
	var triggers = get_tree().get_nodes_in_group("scene_transitions")
	for trigger in triggers:
		trigger.triggered.connect(on_scene_transitions)
	
	# And doors
	var doors = get_tree().get_nodes_in_group("doors")
	for door in doors:
		door.triggered.connect(on_scene_transitions)


func _swap_player_control_state() -> void:
	if (current_player_state == player_states.User_Controlled):
		current_player_state = player_states.System_Controlled
	else:
		current_player_state = player_states.User_Controlled

##Causes the player to take knockback. Direction values are multiplied by force to determine velocity. Disables most movement for knockbackTime seconds.
func take_knockback(force: float, direction: Vector2):
	#print("PLAYER KNOCKBACK RECEIVED")

	if not knockedback:
		inKnockback = true
		knockedback=true #the player has been knocked back and hasn't touched the ground yet
		direction.y-=1
		velocity+=force*direction
		await get_tree().create_timer(knockbackTime).timeout
		inKnockback = false


func _on_hitbox_impacted() -> void:
	gauge.needle_angle = gauge.needle_angle + 15.0
	if gauge.needle_angle >= 270.0:
		gauge.needle_angle = 0
		health.set_health(health.health + 1)

func interactablePrompt(toggle: bool) -> void:
	if(toggle):
		interaction.show()
		interaction.displayInteration()
	else:
		interaction.hide()


func _on_hazard_detect_body_entered(body: Node2D) -> void:
	if body is TileMapLayer and body.name == "Hazard":
		health.set_health(health.health - 1)
		position = last_position
