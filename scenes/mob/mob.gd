extends RigidBody2D

@export var boom: AudioStreamPlayer2D 
var is_dead : bool = false

func _ready() -> void:
	#var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	#$AnimatedSprite2D.play(mob_types[randi() % mob_types.size()])
	$AnimatedSprite2D.play("idle")
func _process(_delta: float) -> void:
	pass

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_health_health_depleted() -> void:
	boom.play()
	$AnimatedSprite2D.sprite_frames.set_animation_loop("die", false)
	$AnimatedSprite2D.play("die")
	await $AnimatedSprite2D.animation_finished 
	boom.stop()
	queue_free()
