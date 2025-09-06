class_name HurtBox
extends Area2D 

signal received_damage(damage: int)

@export var health: Health


func _ready(): 
	connect("area_entered", _on_area_entered)


func _on_area_entered(area) -> void:
	if area != null && (area.get("name") == "HitBox"): # Slightly redundant, the only area that should be detected are mob hitboxes due to physics masks
		health.health -= area.damage 
		received_damage.emit(area.damage) 
