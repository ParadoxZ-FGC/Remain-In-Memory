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

@export_category("Attack")

##Duration that the hitbox is enabled (in seconds).
@export_range(0, 1, 0.01, "or_greater") var duration: float

##Duration that the attack/hitbox is on cooldown (in seconds).
@export_range(0.02, 5, 0.01, "or_greater") var attackCooldown: float

##Number of attacks in a combo.
@export_range(1, 5, 1.0, "or_greater") var multiattack: int

##Time allowed between two combo attacks.
@export_range(0.05, 5, 0.05, "or_greater") var comboDuration: float

##Separate duration that a multiattack is on cooldown for (in seconds). Essentially, the last attack will have this cooldown, whether the player hits all of them or drops the combo.
@export_range(0.25, 5, 0.05, "or_greater") var comboCooldown: float

##Number of hurtboxes to deal damage to in one attack.
@export_range(1, 25, 1.0, "or_greater") var pierce: int

##What type of attack this node represents.
enum codeAttackList {Stationary = 1, Melee = 2, Projectile = 3}
@export_enum("Stationary", "Melee", "Projectile") var attackType: int

##The number of hurtboxes a hitbox can interact with.
var pierceCount: int

##Whether or not the player is attacking.
var attacking: bool = false

##Whether or not the attack is on cooldown.
var attackCooling: bool = false

##Tracks how long it's been between attacks in a combo.
@onready var comboTimer: float = comboDuration

##Whether or not a combo is currently running.
var withinCombo: bool = false

##How many hits have been performed in the current combo.
var comboCounter: int = 0

##Stores $Sprite (or equivalent).
var sprite

##Stores this attack's hitboxes in an array.
var hitboxes = []

##Stores whether the number of provided hitboxes equals the number of hits in a multihit combo. If not (or if there is no combo) this is set to yes, and only the first hitbox will be used.
var isSingleHitbox: bool

##Whether or not the combo is on cooldown.
var comboCooling: bool = false

@onready var parent = get_parent()

#func _get_property_list():
#	if Engine.is_editor_hint():
#		var ret = []
#		return ret

func _ready() -> void:
	var children = get_children()
	for x in children:
		if x.is_class("Sprite2D") or x.is_class("AnimatedSprite2D"):
			sprite = x
		elif x.is_class("Area2D"):
			hitboxes.append(x)
			x.hitboxType = attackType
	
	if hitboxes.size() < multiattack:
		isSingleHitbox = true
	else:
		isSingleHitbox = false

func _physics_process(delta: float) -> void:
	if withinCombo:
		if comboTimer > 0:
			comboTimer -= delta
		else:
			comboTimer = comboDuration
			withinCombo = false
			comboCounter = 0
			comboCooling = true
			await get_tree().create_timer(comboCooldown).timeout
			comboCooling = false

##Processes attacks, combos, and requests hitboxes to activate.
func attack():
	if not attackCooling and not comboCooling:
		var hitbox
		if multiattack:
			if isSingleHitbox:
				hitbox = hitboxes[0]
			else:
				hitbox = hitboxes[comboCounter]
			comboCounter += 1
			if comboCounter >= multiattack:
				comboTimer = 0
			else:
				comboTimer = comboDuration
		else:
			hitbox = hitboxes[0]
		
		attackCooling = true
		hitbox.activate(pierce)
		sprite.set_visible(true)
		attacking = true
		if multiattack > 1:
			withinCombo = true
		
		await get_tree().create_timer(duration).timeout #@TODO May be changed to await animation ended signal when those are more set in stone
		sprite.set_visible(false)
		attacking = false

		await get_tree().create_timer(attackCooldown).timeout
		
		attackCooling = false

##Tells the parent to take knockback
func apply_knockback(force: float):
	parent.take_knockback(force, $"Knockback Direction".position)
