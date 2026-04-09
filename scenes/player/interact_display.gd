extends TextureRect

var lastControlScheme := 0

@onready var icon := $MarginContainer/Icon
@onready var text := $MarginContainer/Text

func _input(_event: InputEvent) -> void:
	if(!is_visible_in_tree()): return
	if(lastControlScheme != ControlSwitch.controlType):
		displayInteration()

# From processInputString, determine if a relevant icon exists
func displayInteration() -> void:
	lastControlScheme = ControlSwitch.controlType
	var s : String = ControlSwitch.processInputString(InputMap.action_get_events("interact")[lastControlScheme])
	var filename := "res://assets/visual/ui/controls/" + s + ".png"
	if (!ResourceLoader.exists(filename)):
		text.add_theme_font_size_override("font_size",32.0 / sqrt(s.length()))
		text.text = s
		icon.texture = null
		return
	text.text = ""
	icon.texture = load(filename)

#Following code is copied from input_editor.gd

# For any InputEvent, derive a human-friendly name
func processInputString(ie: InputEvent) -> String:
	if(ie == null): return "[ ]" #In the case that only one control method exists
	var n = ie.as_text()
	if(n.contains("Mouse Button")): return n.left(1) + "MB"
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
