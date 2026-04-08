extends Control

var setting_name := ""
var kbm : InputEvent # Keyboard+Mouse Keybind from InputMap
var con : InputEvent # Controller Keybind from InputMap
var togglePriority := -1	#   -1 when queued-to/is off
							#  0/2 to maintain KBM
							#  1/3 to maintain con
@onready var kbmButton := $"PanelContainer/MarginContainer/HBoxContainer/KBM-Choice"
@onready var conButton := $"PanelContainer/MarginContainer/HBoxContainer/Con-Choice"

# EditBinding signal manages togglestate for buttons.
func _init() -> void:
	EventBus.connect("editBinding", _editBinding)

# Leftside button selection. Handles KBM input
func _on_kbm_choice_pressed() -> void:
	if(togglePriority == -1): # Check if already in a state
		togglePriority = 2
		kbmButton.release_focus()
		EventBus.emit_signal("editBinding")

# Rightside button selection. Handles Controller input
func _on_con_choice_pressed() -> void:
	if(togglePriority == -1): # Check if already in a state
		togglePriority = 3
		conButton.release_focus()
		EventBus.emit_signal("editBinding")

# Sets the visual UI configurations of the input editor node
func configOption(action: String, label: String) -> void:
	setting_name = action
	$PanelContainer/MarginContainer/HBoxContainer/SettingName.text = "[b]" + label + "[/b]"
	kbmButton.toggle_mode = true
	conButton.toggle_mode = true
	updateButtons()
	
# Specifically updates the current-input-binding buttons to reflect the InputMap
func updateButtons() -> void:
	if(InputMap.action_get_events(setting_name).size() == 2):
		kbm = InputMap.action_get_events(setting_name)[0]
		con = InputMap.action_get_events(setting_name)[1]
	#else:
		#print()
		#print("ISSUE!")
		#print(InputMap.action_get_events(setting_name))
	#kbmButton.text = processInputString(kbm)
	#conButton.text = processInputString(con)
	processInputDisplay(kbmButton, kbm)
	processInputDisplay(conButton, con)

# From processInputString, determine if a relevant icon exists
func processInputDisplay(n: Node, ie: InputEvent):
	var s : String = ControlSwitch.processInputString(ie)
	var filename := "res://assets/visual/ui/controls/" + s + ".png"
	if (!ResourceLoader.exists(filename)):
		n.text = s
		n.icon = null
		#print(filename)
		return
	n.text = ""
	n.icon = load(filename)

# Track inputs for re-binding
func _input(event: InputEvent) -> void:
	if(event is InputEventMouseMotion): return
	if(togglePriority == -1): return
	if(event is InputEventJoypadMotion && absf(event.axis_value) < 0.5 && !(event.axis == 4 || event.axis == 5)): return
	if(event is InputEventMouseButton && event.double_click):
		event.double_click = false;
	updateBinding(event)

# Updates input bindings by editing the specific control method and recreating
# the entry in the InputMap to preserve index order
func updateBinding(input: InputEvent):
	if(togglePriority == 0 && !input.is_action(setting_name)): kbm = input
	elif(togglePriority == 1 && !input.is_action(setting_name)): con = input
	InputMap.action_erase_events(setting_name)
	InputMap.action_add_event(setting_name,kbm)
	InputMap.action_add_event(setting_name,con)
	#print()
	#print("Input Swap!")
	#print(InputMap.action_get_events(setting_name))
	updateButtons()
	EventBus.emit_signal("editBinding")

# When the editBinding signal is emitted, determine how the button will respond.
# -1 -> Both buttons are already off and stay off
#  0 -> The KBM button is on and is set off
#  1 -> The Con button is on and is set off
#  2 -> The KBM button was turned on and will turn off next emit
#  3 -> The Con button was turned on and will turn off next emit
func _editBinding():
	if(togglePriority <= 1): togglePriority = -1
	if(togglePriority == -1 || togglePriority == 3):
		kbmButton.set_pressed_no_signal(false)
	if(togglePriority == -1 || togglePriority == 2):
		conButton.set_pressed_no_signal(false)
	if(togglePriority > 1): togglePriority -= 2
