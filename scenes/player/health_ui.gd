extends CanvasLayer

@onready var hearts = get_children()
@onready var health = get_child_count() * 2
@onready var currentHeart = get_child_count() - 1


func _on_health_health_changed(diff) -> void:
	
	diff = absi(diff)
	
	if ((health - diff) < 0):
		diff = diff + (health - diff)
		
	for i in range(diff):
		health -= 1
		hurt()


func hurt() -> void:
	
	var heart = hearts[currentHeart].get_children()
	heart.reverse()
	for heartState in heart:
		if (heartState.visible):
			heartState.visible = false
			if (heartState.name == "Heart-Half" && health > 0):
				currentHeart -= 1
			break


func heal() -> void:
	
	var previousState = null
	var heart = hearts.get(currentHeart).get_children()
	heart.reverse()
	for heartState in heart:
		if (previousState != null && heartState.visible):
			previousState.visible = true
			if (previousState.name == "Heart-Full"):
				currentHeart += 1
			break
		else:
			previousState = heartState

#func _on_health_max_health_changed(diff: int) -> void:
	#var newHeart = hearts.get(currentHeart).duplicate()
	#if (diff > 0): # Add hearts
		#for i in range(diff):
			#pass
	#else: # Remove hearts
		#for i in range(absi(diff)):
			#pass
