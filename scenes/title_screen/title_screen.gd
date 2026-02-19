extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Settings.released_focus.connect(focus)
	focus()

func focus() -> void:
	$PlayButton.call_deferred("grab_focus")
