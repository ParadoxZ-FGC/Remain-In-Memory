extends WorldScene


var morose : CharacterBody2D

@onready var boss_spawn_location := $BossSpawnLocation
@onready var morose_cutscene_sprite := $MoroseThrone
@onready var boss_left_bound := $BossBoundary/Left
@onready var boss_right_bound := $BossBoundary/Right
@onready var boss_target := $Player


func ready_additions() -> void:
	pass


func _on_boss_trigger_body_entered(_body: Node2D) -> void:
	$BossTrigger.set_deferred("monitoring", false)
	DialogueManager.load_dialogue_scene("prologue_boss")
	EventBus.finish_cutscene.connect(_finish_boss_cutscene)
	
func _finish_boss_cutscene() -> void:
	morose_cutscene_sprite.visible = false
	morose = preload("res://scenes/bosses/morose/prologue_morose.tscn").instantiate()
	morose.target = boss_target
	morose.left_edge = boss_left_bound
	morose.right_edge = boss_right_bound
	morose.position = boss_spawn_location.position
	add_child(morose)
