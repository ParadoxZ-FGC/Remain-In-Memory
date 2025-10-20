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
@export_range(0, 30, 0.25, "or_greater") var cooldown: float

##What type of attack this node represents.
@export_enum("Melee", "Projectile", "Lobbed") var attackType: int:
	set(value):
		attackType = value
		notify_property_list_changed()

##The number of hurtboxes a hitbox can interact with.
var pierceCount: int

##Whether or not the player is attacking.
var attacking: bool = false

##Whether or not the attack is on cooldown.
var cooling: bool = false

func _get_property_list():
	if Engine.is_editor_hint():
		var ret = []
		if attackType != 0:
			ret.append({
				"name": &"pierceCount",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0,25,1,or_greater"
			})
		return ret

##Processes attacks. Handles hitbox enabling, duration, and cooldown.
func attack(): #Attack (Melee)
	if not cooling:
		cooling = true
		$hitbox.set_enabled(true)
		$sprite.visible = true
		attacking = true
		await get_tree().create_timer(duration).timeout
		$hitbox.set_enabled(false)
		$sprite.visible = false
		attacking = false
		await get_tree().create_timer(cooldown).timeout
		cooling = false
