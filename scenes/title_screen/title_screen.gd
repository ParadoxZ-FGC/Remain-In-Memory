extends Node


@onready var last_focused : Control = $PlayButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.released_focus.connect(focus)
	focus(null)

func focus(_source:Control) -> void:
	last_focused.call_deferred("grab_focus")


func _on_button_focus_entered(source: Control) -> void:
	last_focused = source
