class_name HitBox
extends Area2D 

##HitBox is used to make hitboxes, pretty straight forward.
##
##HitBox should be the child of an "Attack" node, though it's not required and it can be used independently.
##The "layers" exported flag determines what the HitBox can hit (relative to HurtBox).
##Requires a CollisionShape2D node as a child, as well as a RayCast2D with no collision mask for Melee hitboxes.

##Currently unused
@warning_ignore("unused_signal")
signal impacted

##Whether or not the hitbox is currently able to scan and interact with hurtboxes. Removed from export as it's not the source of functionality anymore.
var enabled: bool = true: set = set_enabled, get = get_enabled

##Numerical value for how much damage a hitbox will impart on the parent of any hurtbox it scans
@export var damage: int = 1: set = set_damage, get = get_damage

##ALERT Was having trouble getting this to work with the export. Changing it there would not change it in code.
@export var selfKnockback: float = 350.0: set = set_self_knockback, get = get_self_knockback

##Determines the type of attack, and thus the hitboxes' behavior. Use Stationary for constant enemy hitboxes, and Projectile for projectiles. Currently there is no difference but @TODO that will change.
enum codeAttackList {Stationary = 0, Melee = 1, Projectile = 2}
@export_enum("Stationary", "Melee", "Projectile") var hitboxType: int

##What masks* the hitbox belongs to, if one is enabled, any hurtbox that the hitbox scans for will take damage
@export_flags("HitEnvironment:2", "HitBreakable:4", "HitPlayer:8", "HitEnemy:64", "HitHazard:512") var layers : int = 0
#INFO Hitboxes scan for Hurtboxes, so if a Hitbox "Hit(s)Player" that means it will scan any Hurtboxes labeled "Player"

@onready var parent = get_parent()

##Stores a raycast2d that collides with the environment.
var ray

#region Setters and Getters
func set_enabled(x: bool):
	enabled = x
	set_deferred("monitoring", x)

func get_enabled():
	return enabled

func set_damage(value: int):
	damage = value

func get_damage() -> int:
	return damage 

func set_self_knockback(x: bool):
	selfKnockback = x

func get_self_knockback():
	return selfKnockback
#endregion

##Automatically updates collision masks based on the export flags masks
func update_mask():
	collision_mask = layers

func _ready():
	set_enabled(enabled)
	update_mask()
	
	await get_tree().create_timer(0.05).timeout #Buffer, without it nothing is guaranteed to be loaded yet.
	if hitboxType == codeAttackList.Melee:
		for x in get_children():
			if x.is_class("RayCast2D"):
				ray = x
		
		ray.set_collision_mask_value(2, true)

func _physics_process(_delta: float) -> void:
	if hitboxType == codeAttackList.Stationary and monitoring:
		activate(-1)

##Causes the hitbox to scan for overlapping areas. It sorts them by distance and culls any past walls (in the case of Melee hitboxes) and any past the provided pierce count.
func activate(pierce: int):
	var overlap = get_overlapping_areas()
	if overlap.size() > 0:
		overlap.sort_custom(sort_distance)
	
	var hits = []

	if hitboxType == codeAttackList.Melee and ray.is_colliding():
		for x in overlap:
			if x.global_position.distance_to(parent.global_position) <= ray.get_collision_point().distance_to(parent.global_position):
				hits.append(x)
	else:
		hits = overlap
	
	if pierce >= 0:
		if hits.size() > pierce:
			hits.resize(pierce + 1)
	
	for x in hits:
		x.take_damage(damage)
	
	if hitboxType == codeAttackList.Melee and ray.is_colliding() and hits.size() == 0 and selfKnockback > 0:
		parent.apply_knockback(selfKnockback)

##Sorter function, using custom_sort it will sort from nearest to the hitboxes' parent to farthest.
func sort_distance(a, b):
	pass
	if a.global_position.distance_to(parent.global_position) < b.global_position.distance_to(parent.global_position):
		return true
	return false

##Shorthand function to disable the hitbox.
func disable():
	set_enabled(false)

##Shorthand function to enable the hitbox.
func enable():
	set_enabled(true)
