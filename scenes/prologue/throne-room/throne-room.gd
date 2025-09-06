extends WorldScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_scene_transitions_to_player()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
