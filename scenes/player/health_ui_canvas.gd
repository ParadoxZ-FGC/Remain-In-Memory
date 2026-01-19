extends CanvasGroup


@onready var display_hearts = get_children()
@onready var health = floori(PlayerData.maximum_health)
@onready var hearts = 1
@onready var current_heart = get_child_count() - 1


func _ready() -> void:
	var hearts_to_add = (health / 2.0) - 1
	generate_display_hearts(hearts_to_add)


func generate_display_hearts(to_add: int) -> void:
	for i in range(0, to_add):
		var heart : AnimatedSprite2D = display_hearts.back().duplicate()
		heart.position.x += 17
		display_hearts.append(heart)
		add_child(heart)
		heart.name = "Heart"
		current_heart += 1
		hearts += 1


func enable() -> void:
	for heart in display_hearts:
		heart.visible = true


func disable() -> void:
	for heart in display_hearts:
		heart.visible = false


func _on_health_changed(diff) -> void:
	var signer = signi(diff)
	diff = absi(diff)
	
	if health - diff < 0:
		diff = diff + (hearts - diff)
		
	for i in range(diff):
		if signer == -1:
			health -= 1
			hurt()
		elif signer == 1:
			health += 1
			heal()


func hurt() -> void:
	var heart : AnimatedSprite2D = display_hearts.get(current_heart) if (0 <= current_heart and current_heart < hearts) else null
	if heart == null:
		current_heart += 1
	elif heart.frame == 0:
		current_heart -= 1
		hurt()
	else:
		heart.frame -= 1


func heal() -> void:
	var heart : AnimatedSprite2D = display_hearts.get(current_heart) if (0 <= current_heart and current_heart < hearts) else null
	if heart == null:
		current_heart += 1
	elif heart.frame == 2:
		current_heart += 1
		heal()
	else:
		heart.frame += 1


#func _on_hearts_max_hearts_changed(diff: int) -> void:
	#var newHeart = display_hearts.get(current_heart).duplicate()
	#if (diff > 0): # Add display_hearts
		#for i in range(diff):
			#pass
	#else: # Remove display_hearts
		#for i in range(absi(diff)):
			#pass
