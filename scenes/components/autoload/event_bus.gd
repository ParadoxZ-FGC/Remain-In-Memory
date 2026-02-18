extends Node

#INFO Auto-Loaded script full of signals to use between nodes that may not be easily related.
#To emit, write "EventBus.emit_signal("<signal_name>")
#To recieve, write "EventBus.connect("<signal_name>", _function_name) and make sure you then create the function as well

@warning_ignore_start("unused_signal")
signal interact
signal fileRead
signal start_dialogue
signal dialogue_segment_finished(next_scene:Dictionary)
signal dialogue_segment_parsed(speaker:String, _emotion:String, side:String, dialogue_text:String, responses:Dictionary, next_scene:Dictionary)
signal finish_dialogue(finished_cutscene:String)
signal swap_control_state
signal player_dies
signal editBinding
@warning_ignore_restore("unused_signal")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact.emit()
