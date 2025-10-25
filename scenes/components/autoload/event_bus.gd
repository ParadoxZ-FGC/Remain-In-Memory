extends Node

#INFO Auto-Loaded script full of signals to use between nodes that may not be easily related.
#To emit, write "EventBus.emit_signal("<signal_name>")
#To recieve, write "EventBus.connect("<signal_name>", _function_name) and make sure you then create the function as well

@warning_ignore_start("unused_signal")
signal interact(file)
signal stopInteract
signal fileRead
signal dialogue_segment_finished(next_segment: String)
signal dialogue_segment_parsed(speaker:String, _emotion:String, side:String, dialogue_text:String, responses:Dictionary, next_segment:String)
signal continue_dialogue
signal finish_cutscene
signal swap_control_state
@warning_ignore_restore("unused_signal")

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		continue_dialogue.emit()
