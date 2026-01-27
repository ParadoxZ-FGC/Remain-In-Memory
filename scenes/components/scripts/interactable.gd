class_name Interactable
extends Node2D


enum interaction_type {MANUAL, AUTOMATIC}

@export var type: interaction_type = interaction_type.MANUAL
@export var oneshot := false
@export var enabled := true : set = set_enabled

var interactable: bool = false

@onready var detection := $Area2D


func set_enabled(value : bool):
	enabled = value
	if detection != null:
		detection.set_deferred("monitoring", value)


func _ready():
	EventBus.interact.connect(_on_interaction)
	ready_additions()


## ready_additions() should be overwritten to add additional
## functionality to _ready().
## _ready() will call ready_additions()
func ready_additions() -> void:
	pass


func _on_interaction() -> void:
	if interactable and enabled:
		_interact()


func _on_area_2d_area_entered(_area: Area2D) -> void:
	if type == interaction_type.MANUAL:
		interactable = true
	elif type == interaction_type.AUTOMATIC:
		_interact()


func _on_area_2d_area_exited(_area: Area2D) -> void:
	interactable = false


func _interact() -> void:
	interactable = false
	if oneshot:
		enabled = false
	_trigger_effects()


func _trigger_effects() -> void:
	pass
