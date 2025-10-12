extends Node

#INFO Auto-Loaded script full of signals to use between nodes that may not be easily related.
#To emit, write "EventBus.emit_signal("<signal_name>")
#To recieve, write "EventBus.connect("<signal_name>", _function_name) and make sure you then create the function as well

signal interact(file)
signal stopInteract
signal fileRead
