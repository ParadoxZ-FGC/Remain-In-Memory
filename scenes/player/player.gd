extends CharacterBody2D


signal updated

enum dialogueTypes {None, Chatting, Talking} #TODO I have no idea if we want "passive conversation", like npcs saying things without player input, that's what Chatting is for, just in case
enum player_states {User_Controlled, System_Controlled}

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
@export var knockbackTime: float = 0.05 #Determines how long the player is in knockback, @TODO might move to the knockback function itself
@export var to_scene_on_death := true
@export var death_scene : String

var inKnockback: bool = false #Whether or not the player is in knockback, limits movement.
var coyoteTimer: float = 0
var movementDirection: bool = true #rightward = true
var movementIntentionDirection: bool = true
var movementIntention: float
var scene_transitions
var currentDialogue : dialogueTypes = dialogueTypes.None
var current_player_state : player_states = player_states.User_Controlled
var interactable : bool = false #Is there something to interact with
var interact_scene : String #INFO Interactable currently only handles dialogue, so this would be the file one reads from

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2
@onready var health : Health = $Health
@onready var hearts := $"Health UI"
@onready var dialogueHandler = $DialogueHandler
@onready var player_sprite := $AnimatedPlayerSprite


func _ready():
	health.max_health = PlayerData.maximum_health
	health.health = PlayerData.current_health
	EventBus.start_dialogue.connect(_on_dialogue_start)
	EventBus.finish_dialogue.connect(_text_over)
	EventBus.swap_control_state.connect(_swap_player_control_state)
	#EventBus.connect("interaction_available", _on_interactable)
	#EventBus.connect("interaction_unavailable", _off_interactable)
	#EventBus.connect("finish_dialogue", _text_over)
	$AnimatedPlayerSprite.play()


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
	if currentDialogue != dialogueTypes.Talking and current_player_state == player_states.User_Controlled: #If player isnt in dialogue do normal player activities
		if not inKnockback:
			move(Input.get_axis("move_left", "move_right"), delta) #NOTICE Movement has been move(ment)d to a function
		if Input.is_action_just_pressed("attack"):
			$Sword.attack()
		if interactable and Input.is_action_just_pressed("interact"): #If player can interact (INFO w/ dialogue), and they press the button to, disable normal player activies and engage dialogue.
			currentDialogue = dialogueTypes.Talking
			DialogueManager.load_dialogue_scene(interact_scene)
	
	elif currentDialogue == dialogueTypes.Talking: #If player is in dialogue, only allow interact key which advances it.
		if Input.is_action_just_pressed("interact"):
			pass
			#dialogueHandler.readFile()
	
	elif current_player_state == player_states.System_Controlled:
		move(0, delta)
	
	if velocity.x != 0:
		if is_on_floor(): 
			if !stone.playing:
				stone.play()
		else: 
			stone.stop()
		
	else: 
		stone.stop()
		$AnimatedPlayerSprite.animation = "idle"
	
	if velocity.x != 0 and not inKnockback:
		$AnimatedPlayerSprite.animation = "walk"
		$AnimatedPlayerSprite.flip_v = false
		$AnimatedPlayerSprite.flip_h = velocity.x < 0
		if $Sword.attacking == false:
			$Sword.scale = Vector2(1, 1) if velocity.x > 0 else Vector2(-1, 1)
	
	if velocity.x != 0 and Input.is_action_pressed("run"):
		$AnimatedPlayerSprite.speed_scale = 2
	else:
		$AnimatedPlayerSprite.speed_scale = 1
		
	move_and_slide()


func move(movement_vector, delta):
	movementIntention = movement_vector
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
	
	velocity.x = clamp(velocity.x, -max_run_speed, max_run_speed) if (Input.is_action_pressed("run") and current_player_state == player_states.User_Controlled) else clamp(velocity.x, -max_walk_speed, max_walk_speed)
	
	
	velocity.y += gravity * delta
	
	position = position.clamp(upper, lower)
	
	if is_on_floor():
		coyoteTimer = 0
	else:
		coyoteTimer += delta
		clamp(coyoteTimer, 0, coyote)


func jump():
	velocity.y = -jump_speed


func jump_stop():
	if velocity.y < -100:
		velocity.y = -100


func _unhandled_key_input(event: InputEvent) -> void:
	if (current_player_state == player_states.User_Controlled):
		if (event.is_action_pressed("crouch_look_down")):
			$AnimatedPlayerSprite.scale = Vector2(0.2, 0.1)
			$PlayerCollisionShape.scale = Vector2(1, 0.5)
			$Hurtbox/CollisionShape2D.scale = Vector2(1, 0.5)
			
		elif (event.is_action_released("crouch_look_down")):
			$AnimatedPlayerSprite.scale = Vector2(0.2, 0.2)
			$PlayerCollisionShape.scale = Vector2(1, 1)
			$Hurtbox/CollisionShape2D.scale = Vector2(1, 1)
			
		if (is_on_floor() or coyoteTimer < coyote) and event.is_action_pressed("jump"):
			jump()
		
		if not is_on_floor() and event.is_action_released("jump"):
			jump_stop()
		
	else:
		if (event.is_action_released("crouch_look_down")):
			$AnimatedPlayerSprite.scale = Vector2(0.2, 0.2)
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
	updated.emit()


func connect_triggers():
	var triggers = get_tree().get_nodes_in_group("scene_transitions")
	for trigger in triggers:
		trigger.triggered.connect(on_scene_transitions)


func _swap_player_control_state() -> void:
	if (current_player_state == player_states.User_Controlled):
		current_player_state = player_states.System_Controlled
	else:
		current_player_state = player_states.User_Controlled

##Causes the player to take knockback. Direction values are multiplied by force to determine velocity. Disables most movement for knockbackTime seconds.
func take_knockback(force: float, direction: Vector2):
	if not inKnockback:
		inKnockback = true
		velocity = Vector2(0,0)
		if $AnimatedPlayerSprite.flip_h:
			velocity.x -= force * direction.x
		else:
			velocity.x += force * direction.x
		velocity.y += force * direction.y
		await get_tree().create_timer(knockbackTime).timeout
		velocity = Vector2(0,0)
		inKnockback = false
