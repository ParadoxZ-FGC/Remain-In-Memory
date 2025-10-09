class_name HitBox
extends Area2D 

##HitBox is used to make hitboxes, pretty straight forward.
##
##HitBox should be the child of an "Attack" node, though it's not required and it can be used independently.
##The "layers" exported flag determines what the HitBox can hit (relative to HurtBox).

##Currently unused
signal impacted

##Whether or not the hitbox is currently able to scan and interact with hurtboxes.
@export var enabled: bool = true: set = set_enabled, get = get_enabled

##Numerical value for how much damage a hitbox will impart on the parent of any hurtbox it scans
@export var damage: int = 1: set = set_damage, get = get_damage

##TODO A value that will determine knockback force
@export var knockback: bool = false: set = set_knockback, get = get_knockback

##What masks* the hitbox belongs to, if one is enabled, any hurtbox that the hitbox scans for will take damage
@export_flags("HitEnvironment:2", "HitBreakable:4", "HitPlayer:8", "HitEnemy:64", "HitHazard:512") var layers : int = 0
#INFO Hitboxes scan for Hurtboxes, so if a Hitbox "Hit(s)Player" that means it will scan any Hurtboxes labeled "Player"
#region Setters and Getters
func set_enabled(x: bool):
	enabled = x
	set_deferred("monitoring", x)

func get_enabled():
	return enabled

func set_damage(value: int):
	damage = value

func get_damage() -> int:
	return damage 

func set_knockback(x: bool):
	knockback = x

func get_knockback():
	return knockback
#endregion

##Automatically updates collision masks based on the export flags masks
func update_mask():
	collision_mask = layers

func _ready():
	set_enabled(enabled)
	update_mask()

##Determines what type of hurtbox the hitbox is intersecting with and applies damage (or other effects)
func _on_area_entered(area: HurtBox) -> void:
	if area.get_collision_layer_value(3) or area.get_collision_layer_value(4) or area.get_collision_layer_value(7):
		area.take_damage(damage)
		impacted.emit()
	if knockback:
		pass #TODO Knockback
