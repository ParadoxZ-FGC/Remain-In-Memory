@icon("res://assets/visual/ui/dialogue_bubble.png")
class_name DialogueInteractable
extends Interactable


@export var dialogue_scene : String


func _trigger_effects() -> void:
	DialogueManager.load_dialogue_scene(dialogue_scene)
