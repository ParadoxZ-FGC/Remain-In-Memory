@icon("res://assets/visual/ui/door.png")
class_name DoorInteractable
extends Interactable


signal triggered

@export_enum("Left", "Center", "Right") var spawn_position : int

@export_category("Destination")
@export var level_scene : String
@export var destination : String

@onready var exit_locations = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]


func ready_additions() -> void:
	var result : bool = spawn_position == 1 and type == interaction_type.AUTOMATIC
	assert(not result, "WARNING: Due to overlap, center spawn position should not be used with an automatic door.")


func calculate_exit_positions() -> void:
	var exits = $Exits.get_children()
	for i in range(3):
		exit_locations[i] = exits[i].global_position


func _trigger_effects() -> void:
	PlayerData.destination = destination
	triggered.emit()
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().call_deferred("change_scene_to_file", level_scene)
