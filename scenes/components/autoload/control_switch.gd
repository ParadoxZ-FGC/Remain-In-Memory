extends Node

enum {KBM, CON}
# KBM (0) -> Keyboard and Mouse
# CON (1) -> Controller
@export var controlType = KBM

func _input(event: InputEvent) -> void:
	if(event is InputEventMouse): controlType = KBM
	elif(event is InputEventKey): controlType = KBM
	elif(event is InputEventJoypadButton): controlType = CON
	elif(event is InputEventJoypadMotion && absf(event.axis_value) < 0.5): controlType = CON

# For any InputEvent, derive a human-friendly name
func processInputString(ie: InputEvent) -> String:
	if(ie == null): return "[ ]" #In the case that only one control method exists
	var n = ie.as_text()
	if(n.contains("Mouse Button")): return n.left(1) + "MB"
	if(n.contains("Mouse Wheel")): return "Scrl " + n.rsplit(" ", true, 1)[1]
	if(n.contains(" - Physical")): return n.get_slice(" - Physical",0)
	if(n.contains("Joypad Button")):
		return n.get_slice("(",1).get_slice(")",0).get_slice(",",0)
		#match n.get_slice("(",1).get_slice(",",0):
		#	pass #future inplementations
	if(n.contains("Joypad Motion")):
		if(n.contains("Trigger")):
			return n.get_slice(", ",1)
		if(n.contains("Axis")):
			return n.get_slice("(",1).get_slice("-Axis",0).left(-2) + " " + (("Left" if n.contains("Value -") else "Right") if n.contains("X-Axis") else ("Up" if n.contains("Value -") else "Down"))
		return n.get_slice("(",1).get_slice(",",0)
	return n
