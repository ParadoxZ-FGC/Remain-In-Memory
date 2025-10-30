extends CharacterBody2D

signal updated

@export var upper = Vector2(0, 0)
@export var lower = Vector2(2500, 1080)
@export var speed = 1000
@export var jump_speed = 800
@export var coyote: float = 0.03 #How long the player has to input a jump after walking off of a platform. Makes the game feel better.
@export var max_walk_speed = 300
@export var max_run_speed = 500
@export var stop_force = 8000 #friction
@export var drag_force = 500 #friction, but for air
@export var stone: AudioStreamPlayer2D
@export var knockbackTime: float = 0.05 #How long the player is in knockback, may move to takeKnockback function.
var inKnockback: bool = false #Disables most movement.

var coyoteTimer: float = 0
var movementDirection: bool = true #rightward = true
var movementIntentionDirection: bool = true
var movementIntention: float

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2
@onready var health : Health = $Health
@onready var dialogueHandler = $DialogueHandler

var scene_transitions
enum dialogueTypes {None, Chatting, Talking} #TODO I have no idea if we want "passive conversation", like npcs saying things without player input, that's what Chatting is for, just in case
var currentDialogue : int = dialogueTypes.None
var interactable : bool = false #Is there something to interact with
var interactFile : String #INFO Interactable currently only handles dialogue, so this would be the file one reads from

func _ready():
	health.max_health = PlayerData.maximum_health
	health.health = PlayerData.current_health
	EventBus.connect("interact", _on_interactable)
	EventBus.connect("stopInteract", _off_interactable)
	EventBus.connect("fileRead", _text_over)

func _on_interactable(file): #Signals when overlapping interactable
	interactable = true
	interactFile = file

func _off_interactable(): #Signals when leaving interactable #BUG/ALERT This will almost definitely cause issues with multiple interactables close enough to eachother to both be overlapped by the player.
	interactable = false
	interactFile = ""

func _text_over(): #Signals when dialogue file is done
	currentDialogue = dialogueTypes.None

func _physics_process(delta):
	if currentDialogue != dialogueTypes.Talking: #If player isnt in dialogue do normal player activities
		if not inKnockback:
			move(delta) #NOTICE Movement has been move(ment)d to a function
		if Input.is_action_just_pressed("attack"):
			$Sword.attack()
		if interactable and Input.is_action_just_pressed("interact"): #If player can interact (INFO w/ dialogue), and they press the button to, disable normal player activies and engage dialogue.
			currentDialogue = dialogueTypes.Talking
			dialogueHandler.openFile(interactFile)
			dialogueHandler.readFile()
		
	elif currentDialogue == dialogueTypes.Talking: #If player is in dialogue, only allow interact key which advances it.
		if Input.is_action_just_pressed("interact"):
			dialogueHandler.readFile()
	
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
		if not inKnockback:
			$AnimatedPlayerSprite.animation = "walk"
			$AnimatedPlayerSprite.flip_v = false
			$AnimatedPlayerSprite.flip_h = velocity.x < 0
			if $Sword.attacking == false:
				$Sword.scale = Vector2(1, 1) if velocity.x > 0 else Vector2(-1, 1)
	else:
		$AnimatedPlayerSprite.animation = "idle"
	
	move_and_slide()

func move(delta):
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
	
	position = position.clamp(upper, lower)
	
	if is_on_floor():
		coyoteTimer = 0
	else:
		coyoteTimer += delta
		clamp(coyoteTimer, 0, coyote)
	
	if (is_on_floor() or coyoteTimer < coyote) and Input.is_action_just_pressed("jump"):
		jump()
	
	if not is_on_floor() and Input.is_action_just_released("jump"):
		jump_stop()

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
	var title_screen = preload("res://scenes/title-screen/title-screen.tscn")
	PlayerData.current_health = PlayerData.maximum_health
	get_tree().call_deferred("change_scene_to_packed", title_screen)


func on_scene_transitions() -> void:
	PlayerData.maximum_health = health.max_health
	PlayerData.current_health = health.health
	updated.emit()

func connect_triggers():
	var triggers = get_tree().get_nodes_in_group("scene_transitions")
	for trigger in triggers:
		trigger.triggered.connect(on_scene_transitions)

##Causes the player to take knockback. Direction values are multiplied by force to determine velocity. Disables most movement for knockbackTime seconds.
func take_knockback(force: float, direction: Vector2):
	if not inKnockback:
		inKnockback = true
		velocity = Vector2(0,0)
		print(force)
		if $AnimatedPlayerSprite.flip_h:
			velocity.x -= force * direction.x
		else:
			velocity.x += force * direction.x
		velocity.y -= force * direction.y
		await get_tree().create_timer(knockbackTime).timeout
		inKnockback = false
		velocity = Vector2(0,0)
