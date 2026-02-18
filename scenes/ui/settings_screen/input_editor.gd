extends Control

var setting_name = ""
var kbm # Keyboard+Mouse Keybind from InputMap
var con # Controller Keybind from InputMap
var togglePriority = -1 #   -1 when queued-to/is off
						#  0/2 to maintain KBM
						#  1/3 to maintain con

# EditBinding signal manages togglestate for buttons.
func _init() -> void:
	EventBus.connect("editBinding", _editBinding)

# Leftside button selection. Handles KBM input
func _on_kbm_choice_pressed() -> void:
	if(togglePriority == -1): # Check if already in a state
		togglePriority = 2
		EventBus.emit_signal("editBinding")

# Rightside button selection. Handles Controller input
func _on_con_choice_pressed() -> void:
	if(togglePriority == -1): # Check if already in a state
		togglePriority = 3
		EventBus.emit_signal("editBinding")

# Sets the visual UI configurations of the input editor node
func configOption(action: String, label: String) -> void:
	setting_name = action
	$PanelContainer/MarginContainer/HBoxContainer/SettingName.text = "[b]" + label + "[/b]"
	$"PanelContainer/MarginContainer/HBoxContainer/KBM-Choice".toggle_mode = true
	$"PanelContainer/MarginContainer/HBoxContainer/Con-Choice".toggle_mode = true
	updateButtons()
	
# Specifically updates the current-input-binding buttons to reflect the InputMap
func updateButtons() -> void:
	if(InputMap.action_get_events(setting_name).size() == 2):
		kbm = InputMap.action_get_events(setting_name)[0]
		con = InputMap.action_get_events(setting_name)[1]
	else:
		print()
		print("ISSUE!")
		print(InputMap.action_get_events(setting_name))
	$"PanelContainer/MarginContainer/HBoxContainer/KBM-Choice".text = processInputString(kbm.as_text())
	$"PanelContainer/MarginContainer/HBoxContainer/Con-Choice".text = processInputString(con.as_text())

# For any InputEvent, derive a human-friendly name
func processInputString(n: String) -> String:
	if(n.contains(" - Physical")): return n.get_slice(" - Physical",0)
	if(n.contains("Joypad Button")):
		return n.get_slice("(",1).get_slice(",",0)
		#match n.get_slice("(",1).get_slice(",",0):
		#	pass #future inplementations
	if(n.contains("Joypad Motion")):
		if(n.contains("Trigger")):
			return n.get_slice(",",1).get_slice(",",0)
		if(n.contains("D-pad")):
			return n.get_slice("(",1).get_slice(")",0)
		if(n.contains("Axis")):
			return n.get_slice("(",1).get_slice("-Axis",0).left(-2) + " " + (("Left" if n.contains("Value -") else "Right") if n.contains("X-Axis") else ("Down" if n.contains("Value -") else "Up"))
		return n.get_slice("(",1).get_slice(",",0)
	return n

# Track inputs for re-binding
func _input(event: InputEvent) -> void:
	if(event is InputEventMouseMotion): return
	if(togglePriority == -1): return
	updateBinding(event)

# Updates input bindings by editing the specific control method and recreating
# the entry in the InputMap to preserve index order
func updateBinding(input: InputEvent):
	if(togglePriority == 0): kbm = input
	elif(togglePriority == 1): con = input
	InputMap.action_erase_events(setting_name)
	InputMap.action_add_event(setting_name,kbm)
	InputMap.action_add_event(setting_name,con)
	print()
	print("Input Swap!")
	print(InputMap.action_get_events(setting_name))
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
		$"PanelContainer/MarginContainer/HBoxContainer/KBM-Choice".set_pressed_no_signal(false)
	if(togglePriority == -1 || togglePriority == 2):
		$"PanelContainer/MarginContainer/HBoxContainer/Con-Choice".set_pressed_no_signal(false)
	if(togglePriority > 1): togglePriority -= 2
