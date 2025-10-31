extends Button


func _on_pressed() -> void:
	if name == "PlayButton":
		get_tree().change_scene_to_file("res://scenes/prologue/mountain-path/intro.tscn")
	else:
		get_tree().quit()
