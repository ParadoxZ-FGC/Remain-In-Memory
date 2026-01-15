class_name HurtBox
extends Area2D 

##HurtBox is used to make hurtboxes, pretty straight forward.
##
##HurtBox is able to be used fully independently, just drag the HurtBox in as a child of whatever you want to inflict pain upon.
##The "layers" exported flag determines what the HurtBox can be hit by (relative to HitBox).

##Whether or not the hurtbox is currently able to be scanned and interacted with.
@export var enabled: bool = true: set = set_enabled, get = get_enabled

##What layers the hurtbox belongs to, if one is enabled, any hitbox that hits that layer will deal damage.
@export_flags("Environment:2", "Breakable:4", "Player:8", "Enemy:64", "Hazard:512") var layers = 0
#INFO Hurtboxes get scanned by Hitboxes, so if a Hurtbox is labeled "Player" that means it will be scanned by Hitboxes labeled "HitPlayer"
#region Setters and Getters
func set_enabled(x: bool):
	enabled = x
	set_deferred("monitorable", x)

func get_enabled():
	return enabled
#endregion

##Automatically updates collision layers based on the export flags layers
func update_layers():
	collision_layer = layers

func _ready():
	set_enabled(enabled)
	update_layers()

##Reduces the HP value of the hurtbox's parent
func take_damage(x : int):
	var HP = get_parent().find_child("Health")
	HP.set_health(HP.health - x)
