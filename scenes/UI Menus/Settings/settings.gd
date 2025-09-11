extends Control 

@export var exit_settings: Button

var was_paused = false


func _ready():
	hide()  # Ensure settings start hidden
	exit_settings.pressed.connect(_on_exit_settings_pressed)  # Ensure signal is connected


func open_settings(from_pause_menu: bool):
	was_paused = get_tree().paused  # Store current pause state

	if not from_pause_menu:
		get_tree().paused = true  # Only pause if from title screen 

	show()  # Show the settings menu


func exit_settings_menu():  
	exit_settings.release_focus()
	hide()  # Hide settings menu
	
	# Unpause only if it was accessed from the title screen
	if not was_paused:
		get_tree().paused = false  
	else:
		get_parent()._on_return_settings()


func _on_exit_settings_pressed():
	exit_settings_menu()


func _process(_delta):
	if Input.is_action_just_pressed("esc") and visible:
		exit_settings_menu()


func _on_settings_button_pressed() -> void:
	open_settings(true) # Replace with function body.
