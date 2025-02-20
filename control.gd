extends Control

var pausescreen
var settings 
var setBo = false 

func resume():
	hide()
	get_tree().paused = false 
	$AnimationPlayer.play_backwards("pause")

func pause(): 
	show()
	get_tree().paused = true 
	$AnimationPlayer.play("pause") 
	
	


func testEsc(): 
		if Input.is_action_just_pressed("escape") and !get_tree().paused:
			pause()
		elif Input.is_action_just_pressed("escape") and get_tree().paused and !setBo:
			resume()  
		elif Input.is_action_just_pressed("escape") and get_tree().paused and setBo: 
			homePause()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide() # Replace with function body.
	pausescreen = get_node("PauseScreen")
	settings = get_node("Settings") 



func _on_resume_pressed() -> void:
	resume() # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit() # Replace with function body.

func _process(delta):
	testEsc()


func _on_settings_pressed() -> void:
	pausescreen.leave() 
	settings.entry()
	setBo = true
	pass # Replace with function body. 

func homePause():
	settings.leave()
	pausescreen.entry()
	setBo = false 

func _on_back_pressed() -> void:
	homePause()
