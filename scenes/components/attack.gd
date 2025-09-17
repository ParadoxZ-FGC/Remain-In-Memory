@tool extends Node2D

@export_category("Attack")
@export_range(0, 1, 0.01, "or_greater") var duration: float
@export_enum("Melee", "Projectile", "Lobbed") var attackType: int:
	set(value):
		attackType = value
		notify_property_list_changed()

var pierceCount: int
var attacking: bool = false

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

func attack():
	$hitbox.set_enabled(true)
	$sprite.visible = true
	attacking = true
	await get_tree().create_timer(duration).timeout
	$hitbox.set_enabled(false)
	$sprite.visible = false
	attacking = false
