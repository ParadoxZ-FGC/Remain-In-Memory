extends Button

@export var scene_to_load: String
@onready var play_sfx = $SFX
#play_sfx.play() play sfx when hit play

func _on_pressed() -> void:
	if name == "PlayButton":
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		get_tree().change_scene_to_file(scene_to_load)
	else:
		get_tree().quit()
