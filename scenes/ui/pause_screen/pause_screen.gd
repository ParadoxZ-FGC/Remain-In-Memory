extends Control 

@export var resume_button: Button
@export var scene: PackedScene 
@export var settings: Node  # Ensure this references the settings node 
@export var vbox: VBoxContainer
@export var rect: ColorRect


func _ready():
	rect.material.set_shader_parameter("lod", 0)
	visible = true
	settings.hide()
	for child in $PanelContainer/MarginContainer/VBoxContainer.get_children():
		if child is not HSeparator:
			child.disabled = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		if settings.visible:
			settings.exit_settings_menu()  # Close settings first if it's open
		elif get_tree().paused:
			resume()
		else:
			pause()


func resume():  
	resume_button.release_focus()
	get_tree().paused = false
	for child in $PanelContainer/MarginContainer/VBoxContainer.get_children():
		if child is not HSeparator:
			child.disabled = true
	$AnimationPlayer.play_backwards("blur")


func pause():
	get_tree().paused = true
	for child in $PanelContainer/MarginContainer/VBoxContainer.get_children():
		if child is not HSeparator:
			child.disabled = false
	$AnimationPlayer.play("blur")


func _on_resume_pressed():
	resume()


func _on_return_settings():
	vbox.show()


func _on_settings_pressed():
	vbox.hide()
	settings.open_settings(true)  # Access settings from pause menu


func _on_title_screen_pressed():
	resume()
	PlayerData.current_health = PlayerData.maximum_health
	get_tree().change_scene_to_packed(scene)


func _on_alt_f_4_pressed():
	resume()
	get_tree().quit()


func _on_restart_for_debugging_pressed():
	resume()
	get_tree().reload_current_scene()
