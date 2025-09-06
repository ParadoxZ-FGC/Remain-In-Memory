class_name Health
extends Node
 
signal max_health_changed(diff: int)
signal health_changed(diff: int)
signal health_depleted 

@export var max_health: int = 3: set = set_max_health, get = get_max_health  
@export var immortality: bool = false: set = set_immortality, get = get_immortality  
@export var immortalityDuration = 1

@onready var health: int = max_health: set = set_health, get = get_health

var immortality_timer: Timer = null


func set_max_health(value : int): 
	
	var clamped_value = 1 if value <= 0 else value
	  
	if not clamped_value == max_health: 
		var difference = clamped_value - max_health  
		max_health = value
		max_health_changed.emit(difference)  
		 
		if health > max_health: 
			health = max_health


func get_max_health() -> int:
	return max_health


func set_immortality(value: bool):
	immortality = value


func get_immortality() -> bool:
	return immortality 
 

func set_temporary_immortality(time: float): 
	if immortality_timer == null: 
		immortality_timer = Timer.new() 
		immortality_timer.one_shot = true 
		add_child(immortality_timer) 
	
	if immortality_timer.timeout.is_connected(resolve_temporary_immortality): 
		immortality_timer.timeout.disconnect(resolve_temporary_immortality) 
	
	immortality_timer.set_wait_time(time)
	immortality_timer.timeout.connect(resolve_temporary_immortality) 
	immortality = true
	get_parent().find_child("HurtBox").set_deferred("monitoring", false)
	immortality_timer.start()


func resolve_temporary_immortality():
	immortality = false
	get_parent().find_child("HurtBox").set_deferred("monitoring", true)


func set_health(value : int): 
	if value < health and immortality: 
		return 
	
	var clamped_value = clampi(value, 0, max_health) 
	if clamped_value != health: 
		var difference = clamped_value - health 
		if (difference < 0):
			set_temporary_immortality(immortalityDuration)
		health = value
		health_changed.emit(difference) 
		
		if health <= 0:
			health_depleted.emit()


func get_health() -> int: 
	return health
