extends Control 

@export var exit_settings: Button

var was_paused = false
var settings_mode = "Sound" # New var for mutliple settings tabs. Currently "Sound" and "Controls"

# All InputMap Actions and their associated managers

func _ready():
	hide()  # Ensure settings start hidden
	exit_settings.pressed.connect(_on_exit_settings_pressed)  # Ensure signal is connected
	get_node("PanelContainer/ControlsTab/settings_container/Esc").configOption("esc", "Exit Menu")
	get_node("PanelContainer/ControlsTab/settings_container/MoveLeft").configOption("move_left", "Move Left")
	get_node("PanelContainer/ControlsTab/settings_container/MoveRight").configOption("move_right", "Move Right")
	get_node("PanelContainer/ControlsTab/settings_container/CrouchDown").configOption("crouch_look_down", "Crouch")
	get_node("PanelContainer/ControlsTab/settings_container/Jump").configOption("jump", "Jump")
	get_node("PanelContainer/ControlsTab/settings_container/Attack").configOption("attack", "Attack")
	get_node("PanelContainer/ControlsTab/settings_container/Interact").configOption("interact", "Interact")
	get_node("PanelContainer/ControlsTab/settings_container/Run").configOption("run", "Sprint")


func open_settings(from_pause_menu: bool):
	was_paused = get_tree().paused  # Store current pause state

	if not from_pause_menu:
		get_tree().paused = true  # Only pause if from title screen 

	checkMode() # Ensure correct mode
	show()  # Show the settings menu


func exit_settings_menu():  
	exit_settings.release_focus()
	EventBus.emit_signal("editBinding")
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

func checkMode(): # Refers to "settings_mode" variable
	EventBus.emit_signal("editBinding")
	if(settings_mode == "Sound"):
		$PanelContainer/SoundTab.show()
		$PanelContainer/ControlsTab.hide()
	if(settings_mode == "Controls"):
		$PanelContainer/SoundTab.hide()
		$PanelContainer/ControlsTab.show()

func _on_settings_button_pressed() -> void:
	open_settings(true) # Replace with function body.


func _on_sound_toggle_pressed() -> void:
	settings_mode = "Sound"
	checkMode()


func _on_controls_toggle_pressed() -> void:
	settings_mode = "Controls"
	checkMode()

#func _input(event: InputEvent) -> void:
#	print(event.as_text())
# For testing input detection
