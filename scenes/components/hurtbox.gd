class_name HurtBox
extends Area2D 

@export var enabled: bool = true: set = set_enabled, get = get_enabled
@export_flags("Environment:2", "Breakable:4", "Player:8", "Enemy:64", "Hazard:512") var layers = 0

#region Setters and Getters
func set_enabled(x: bool):
	enabled = x
	set_deferred("monitorable", x)

func get_enabled():
	return enabled
#endregion

func update_layers():
	collision_layer = layers

func _ready():
	set_enabled(enabled)
	update_layers()

func take_damage(x : int):
	print("Damage Taken")
	var HP = get_parent().find_child("Health")
	HP.set_health(HP.health - x)
