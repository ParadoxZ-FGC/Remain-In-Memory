extends AnimatedSprite2D
 

@onready var hitbox = $HitBox 

func _on_facing_changed(facing_right: bool) -> void: 
	if(facing_right): 
		position.x = 72.5 
		rotate(PI)
	else: 
		position.x = -72.5 
		rotate(PI)

func _ready(): 
	hide()
	hitbox.set_deferred("monitoring", false) 
	hitbox.set_deferred("monitorable", false)  
	
	connect("animation_finished", _on_animation_finished) 

func _process(_delta): 
	if Input.is_action_just_pressed("attack"): 
		attack() 

func attack():
	show() 
	sprite_frames.set_animation_loop("attack", false)
	play("attack")
	
	hitbox.set_deferred("monitoring", true) 
	hitbox.set_deferred("monitorable", true)   
	await animation_finished 
	
	_on_animation_finished()

func _on_animation_finished(): 
	hide()
	if animation == "attack": 
		hitbox.set_deferred("monitoring", false) 
		hitbox.set_deferred("monitorable", false)   
