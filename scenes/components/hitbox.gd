class_name HitBox
extends Area2D 

@export var damage: int = 1: set = set_damage, get = get_damage 

func set_damage(value: int):
	damage = value

func get_damage() -> int:
	return damage 

#func _on_facing_changed(facing_right: bool) -> void: 
#	if(facing_right): 
#		position.x = 59
#	else: 
#		position.x = -59
