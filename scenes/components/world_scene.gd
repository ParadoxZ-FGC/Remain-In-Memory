class_name WorldScene
extends Node2D
## WorldScene should be extended by any scene that the player will be in.
##
## For functions and variables that all scenes that player is in should have.
##
## @experimental

## Collect all scene transitions and connect them to the player.
## Used so player can update PlayerData before scene change.
func connect_scene_transitions_to_player():
	var scene_transitions = find_child("SceneTransitions")
	var player = find_child("Player")
	if scene_transitions != null:
		player.scene_transitions = scene_transitions
		player.connect_triggers()
