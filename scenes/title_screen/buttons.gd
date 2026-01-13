extends Button


func _on_pressed() -> void:
	if name == "PlayButton":
		get_tree().change_scene_to_file("res://scenes/levels/prologue/mountain_path/intro.tscn")
	else:
		get_tree().quit()
