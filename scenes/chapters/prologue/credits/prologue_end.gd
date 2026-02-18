extends Node


var vis_char_tbc = 0
var vis_char_iao = 0
var timer_started = false

@onready var TBC := $ToBeContinued
@onready var IAO := $InAct1
@onready var press_k := $PressK


func _ready() -> void:
	TBC.visible_characters = 0
	IAO.visible_characters = 0
	press_k.visible = false


func _process(delta: float) -> void:
	if TBC.visible_ratio < 1.0:
		vis_char_tbc += delta * 5
		TBC.visible_characters = vis_char_tbc
	elif IAO.visible_ratio < 1.0:
		vis_char_iao += delta * 2
		IAO.visible_characters = vis_char_iao
	elif not timer_started:
		timer_started = true
		_start_timer()


func _start_timer() -> void:
	var timer := get_tree().create_timer(5)
	await timer.timeout
	press_k.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		PlayerData.current_health = PlayerData.maximum_health
		get_tree().call_deferred("change_scene_to_file", "res://scenes/title_screen/title_screen.tscn")
