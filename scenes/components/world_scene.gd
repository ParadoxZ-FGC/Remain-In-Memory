class_name WorldScene
extends Node
## WorldScene should be extended by any scene that the player will be in.
##
## For functions and variables that all scenes that player is in should have.
##
## @experimental

## Emit fade_out when fade_out() has completed
## Allows triggers to know when they can change scenes 
signal fade_out

## The duration of the fade effect
@export var fade_time : float = 1

var _fade := Sprite2D.new()
var _opaque = Color(1, 1, 1, 1)
var _transparent = Color(1, 1, 1, 0)


## _ready() shouldn't be overwritten, use ready_additions
## to add functionality to the _ready() call.
func _ready() -> void:
	_fade.name = "ScreenFade"
	_fade.centered = true
	_fade.texture = load("res://scenes/components/textures/black_texture.tres") # Literally just a flat black texture
	_fade.visible = true
	_fade.modulate = _opaque
	_fade.top_level = true
	_fade.scale = Vector2(1000, 1000)
	add_child(_fade)
	_player_connect_triggers()
	var player = find_child("Player")
	player.updated.connect(_fade_out)
	ready_additions()
	_fade_in()


## ready_additions() should be overwritten to add additional
## functionality to _ready().
## _ready() will call ready_additions()
func ready_additions() -> void:
	pass


## Inform Player that it can connect all scene triggers to itself.
## Used so Player can update PlayerData before scene change.
func _player_connect_triggers() -> void:
	var player = find_child("Player")
	if player != null:
		player.connect_triggers()


## Fade into the scene
func _fade_in() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(_fade, "modulate", _transparent, fade_time)
	

## Fade out to black
func _fade_out() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(_fade, "modulate", _opaque, fade_time)
	await tween.finished
	fade_out.emit()
