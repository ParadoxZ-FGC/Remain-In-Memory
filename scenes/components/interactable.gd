class_name Interactable #INFO Currently only supports dialogue interactions, but I figured I'd make the full class for the future
extends Node2D


enum interaction_type {MANUAL, AUTOMATIC}

@export var type: interaction_type = interaction_type.MANUAL
@export var oneshot := false

var enabled := true : 
	set(x):
		enabled = x
		detection.set_deferred("monitoring", x)
var interactable: bool = false

@onready var detection := $Area2D


func _ready():
	EventBus.interact.connect(_on_interaction)


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
