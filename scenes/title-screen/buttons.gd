extends Button

@export var button_name = "play"
@export var scene = "res://scenes/prologue/tutorial-one/tutorial-one.tscn"

func _ready():
	var button = Button.new()
	button.text = name
	button.pressed.connect(_button_pressed)
	add_child(button)

func _button_pressed():
	if button_name == "play":
		get_tree().change_scene_to_file(scene)
	if button_name == "exit":
		get_tree().quit()
