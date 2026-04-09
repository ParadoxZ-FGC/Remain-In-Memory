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

##Numerical value for how much damage a hitbox will impart on the parent of any hurtbox it scans
@export var damage: int = 1: set = set_damage, get = get_damage

##ALERT Was having trouble getting this to work with the export. Changing it there would not change it in code.
@export var selfKnockback: float = 350.0: set = set_self_knockback, get = get_self_knockback

@export var applyKnockback: float = 350.0

##Determines the type of attack, and thus the hitboxes' behavior. Use Stationary for constant enemy hitboxes, and Projectile for projectiles. Currently there is no difference but @TODO that will change.
enum codeAttackList {Stationary = 0, Moving = 1 }
@export_enum("Stationary", "Moving") var hitboxType: int

##What masks* the hitbox belongs to, if one is enabled, any hurtbox that the hitbox scans for will take damage
@export_flags("HitEnvironment:2", "HitBreakable:4", "HitPlayer:8", "HitEnemy:64", "HitEnemyAttack:128", "HitHazard:512") var layers : int = 0
#INFO Hitboxes scan for Hurtboxes, so if a Hitbox "Hit(s)Player" that means it will scan any Hurtboxes labeled "Player"

##Number of hurtboxes to deal damage to.
@export_range(0, 25, 1.0, "or_greater") var pierce: int

##For use with projectiles, deals damage to parent when hitting environment.
@export var environmentSelfDamage: bool = false

@onready var AttackOwner = get_parent().get_parent().get_parent()

var ray = null

var activated = false

#region Setters and Getters
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
	if environmentSelfDamage:
		monitorable = true

func _ready():
	update_mask()
	
	await get_tree().create_timer(0.05).timeout #Buffer, without it nothing is guaranteed to be loaded yet.
	var rays = $"Environment Raycasts".get_children()
	if rays.size() > 0:
		ray = rays[0]
		ray.set_collision_mask_value(2, true)

func _physics_process(_delta: float) -> void:
	if activated:
		if environmentSelfDamage:
			var bodyOverlap = get_overlapping_bodies()
			for x in bodyOverlap:
				if x is TileMapLayer:
					var HP = get_parent().find_child("Health", true, false)
					HP.set_health(HP.health - damage)

		var overlap = get_overlapping_areas()
		if overlap.size() > 0:
			overlap.sort_custom(sort_distance)

			var hits = []
			if hitboxType == codeAttackList.Moving and (ray and ray.is_colliding()): 
				for x in overlap:
					if x.global_position.distance_to(Vector2(AttackOwner.global_position.x, x.global_position.y)) <= ray.get_collision_point().distance_to(AttackOwner.global_position):
						hits.append(x)
			elif hitboxType == codeAttackList.Stationary and ray:
				for x in overlap:
					ray.target_poistion = x.global_position
					if not ray.is_colliding():
						hits.append(x)
			else:
				hits = overlap
				print(hits)

			if hits.size() > 0:
				if pierce > 0 and hits.size() > pierce:
					hits.resize(pierce)

				for x in hits:
					x.take_damage(damage)
					impacted.emit()

				#if selfKnockback > 0 and (ray.is_colliding() or hits.size() > 0):
					#get_parent().apply_knockback(selfKnockback, $"Knockback Direction".position)

##Causes the hitbox to scan for overlapping areas. It sorts them by distance and culls any past walls and any past the provided pierce count.
func activate(duration: float = -1):
	activated = true
	print(activated)
	if duration >= 0:
		await get_tree().create_timer(duration).timeout
		activated = false

func deactivate():
	activated = false

##Sorter function, using custom_sort it will sort from nearest to the hitboxes' parent to farthest.
func sort_distance(a, b):
	if a.global_position.distance_to(AttackOwner.global_position) < b.global_position.distance_to(AttackOwner.global_position):
		return true
	return false
