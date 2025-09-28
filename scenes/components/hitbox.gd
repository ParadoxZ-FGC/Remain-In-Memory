class_name HitBox
extends Area2D 

signal impacted

@export var enabled: bool = true: set = set_enabled, get = get_enabled
@export var damage: int = 1: set = set_damage, get = get_damage
@export var knockback: bool = false: set = set_knockback, get = get_knockback

@export_flags("HitEnvironment:2", "HitBreakable:4", "HitPlayer:8", "HitEnemy:64", "HitHazard:512") var layers : int = 0

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

func update_mask():
	collision_mask = layers

func _ready():
	set_enabled(enabled)
	update_mask()

func _on_area_entered(area: HurtBox) -> void:
	if area.get_collision_layer_value(3) or area.get_collision_layer_value(4) or area.get_collision_layer_value(7):
		area.take_damage(damage)
		impacted.emit()
	if knockback:
		pass #TODO Knockback
