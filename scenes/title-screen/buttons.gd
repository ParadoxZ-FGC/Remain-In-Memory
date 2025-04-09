extends Button


func _on_pressed() -> void:
	if name == "PlayButton":
		get_tree().change_scene_to_file("res://scenes/prologue/tutorial-one/tutorial-one.tscn")
	else:
		get_tree().quit()
