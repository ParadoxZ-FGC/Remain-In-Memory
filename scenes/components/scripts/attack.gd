@tool extends Node2D
class_name Attack

##Attack is ideally going to become a sort of general/abstract class for all attacks, housing the exact mechanics of each attack (cooldown, type, projectile lifespan, projectile arc, etc)
##
##Currently, it handles attack (hitbox) duration, attack cooldown, and specifically melee attacks (all of em end up being melee atp)
##The export code is black magic and really hard to explain without just pointing you towards documentation
##@tutorial: https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_exports.html
##@tutorial: https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_basics.html#doc-gdscript-tool-mode
##@tutorial: https://gitlab.com/dbat/lessons-in-dev/-/wikis/Get-Property-List-Voodoo
##
##@experimental: MASSIVELY experimental, "barely" functional (it does what it needs to do for now). It still needs a lot of work.

##Duration that the hitbox is enabled (in seconds).
@export_range(0, 1, 0.01, "or_greater") var duration: float

##Duration that the attack/hitbox is on cooldown (in seconds).
@export_range(0.02, 5, 0.01, "or_greater") var attackCooldown: float

##Time allowed between two attacks in a string.
@export_range(0.05, 5, 0.05, "or_greater") var comboDuration: float

##Separate duration that an attack string is on cooldown for (in seconds). Essentially, the last attack will have this cooldown, whether the player hits all of them or drops the combo.
@export_range(0.25, 5, 0.05, "or_greater") var comboCooldown: float

##Whether or not the attack is on cooldown.
var attackCooling: bool = false

##Tracks how long it's been between attacks in a combo.
@onready var comboTimer: float = comboDuration

##Whether or not a combo is currently running.
var withinCombo: bool = false

##How many hits have been performed in the current combo.
var comboCounter: int = 0

##Stores attacks as an array
var attackList = []

##Stores information on contents of attacks (i.e if each attack has a hitbox, sprite, and/or projectile). Key is the specific attack's Node name rather than the node object itself.
var attackDict = {}

##Whether or not the combo is on cooldown.
var comboCooling: bool = false

var attackCount: int

@onready var parent = get_parent()

var firstflip: bool = false

#func _get_property_list():
#	if Engine.is_editor_hint():
#		var ret = []
#		return ret

func _ready() -> void:
	await get_tree().create_timer(0.05).timeout
	for x in get_children():
		attackCount += 1
		var c = Vector3i(0,0,0)
		if x.get_node("Hitbox").get_child_count():
			c += Vector3i(1,0,0)
		if x.get_node("Sprite").get_child_count():
			c += Vector3i(0,1,0)
		if x.get_node("Projectile").get_child_count():
			c += Vector3i(0,0,1)
		attackList.append(x)
		attackDict[x] = c
		#flip_projectiles(true)
		firstflip = true

func _physics_process(delta: float) -> void:
	if withinCombo:
		if comboTimer > 0:
			comboTimer -= delta
		else:
			withinCombo = false
			comboTimer = comboDuration
			comboCounter = 0
			comboCooling = true
			await get_tree().create_timer(comboCooldown).timeout
			comboCooling = false

##Processes attacks, combos, and requests hitboxes to activate.
func attack():
	if not attackCooling and not comboCooling:
		var hitbox = null
		var sprite = null
		var projectile = null
		var currentAttack = attackList[comboCounter]
		var attackInfo = attackDict[currentAttack]
		
		attackCooling = true
		if attackInfo.x == 1:
			hitbox = currentAttack.get_node("Hitbox").get_child(0)
			hitbox.activate(duration)
		if attackInfo.y == 1:
			sprite = currentAttack.get_node("Sprite").get_child(0)
			sprite.set_visible(true)
		if attackInfo.z == 1:
			projectile = currentAttack.get_node("Projectile").get_child(0)
			projectile.fire()
		
		comboCounter += 1
		if comboCounter >= attackCount:
			comboTimer = 0
			comboCounter = 0
		else:
			comboTimer = comboDuration
			if not withinCombo:
				withinCombo = true
		
		await get_tree().create_timer(duration).timeout
		if(sprite):
			sprite.set_visible(false)
		
		await get_tree().create_timer(attackCooldown).timeout
		attackCooling = false

##Tells the parent to take knockback
func apply_knockback(force: float, direction: Vector2):
	parent.take_knockback(force, direction)

func flip_projectiles(ignore : bool = false):
	if not firstflip:
		await get_tree().create_timer(0.05).timeout
	for x in attackList:
		var projectileN = x.get_node("Projectile")
		if  projectileN.get_child_count() > 0:
			projectileN.get_node("ProjectileHandler").flip()
