extends Control

@onready var dialoguePosition = $DialoguePosition
@onready var dialogueManager = $DialogueManager

func _on_weirdbutton_pressed() -> void:
	dialogueManager.show_messages(["weird"], dialoguePosition.position)
