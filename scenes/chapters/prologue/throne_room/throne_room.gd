extends WorldScene


var morose : PrologueBoss

@onready var boss_spawn_location := $BossSpawnLocation
@onready var boss_spawn_particles := $BossSpawnLocation/GPUParticles2D
@onready var morose_cutscene_sprite := $MoroseThrone
@onready var morose_cutscene_sprite_particles := $MoroseThrone/GPUParticles2D
@onready var boss_left_bound := $BossBoundary/Left
@onready var boss_right_bound := $BossBoundary/Right
@onready var boss_target := $Player


func ready_additions() -> void:
	EventBus.finish_dialogue.connect(_post_cutscene_effects)
	EventBus.player_dies.connect(_on_player_death)


func _post_cutscene_effects(cutscene:String) -> void:
	if cutscene == "prologue_boss":
		EventBus.swap_control_state.emit()
		morose_cutscene_sprite_particles.restart()
		var tweenie_weenie = create_tween()
		tweenie_weenie.tween_property(morose_cutscene_sprite, "modulate", Color(0,0,0,0), 3)
		var teenie_timer = get_tree().create_timer(2)
		await teenie_timer.timeout
		
		morose = preload("res://scenes/bosses/morose/prologue_morose_v2.tscn").instantiate()
		morose.modulate = Color(1,1,1,0)
		morose.target = boss_target
		morose.left_edge = boss_left_bound
		morose.right_edge = boss_right_bound
		morose.position = boss_spawn_location.position
		add_child(morose)
		morose.sword.visible = false
		morose.dies.connect(_on_boss_death)
		
		boss_spawn_particles.restart()
		var teenie_timer_twooie = get_tree().create_timer(2)
		await teenie_timer_twooie.timeout
		
		var tweenie_weenie_twooie = create_tween()
		tweenie_weenie_twooie.tween_property(morose, "modulate", Color(1,1,1,1), 5)
		if boss_spawn_particles.emitting:
			await boss_spawn_particles.finished
		if (tweenie_weenie_twooie.is_running()):
			await tweenie_weenie_twooie.finished
		
		EventBus.swap_control_state.emit()
		DialogueManager.load_dialogue_scene("prologue_boss_attacks")
	elif cutscene == "prologue_boss_attacks":
		morose.boss.use_parent_material = false
		morose.sword.visible = true
		morose.stab(-1)
		morose.talking = false
	elif cutscene == "prologue_boss_wins" or cutscene == "prologue_boss_losses":
		EventBus.swap_control_state.emit()
		var cam = $Player/Camera2D
		cam.reparent(get_tree().current_scene)
		var tweent = create_tween()
		tweent.tween_property(cam, "zoom", Vector2(1, 1), 5)
		
		var tweenk = create_tween()
		tweenk.tween_property($ColorRect, "color", Color(0,0,0,1), 5)
		await tweenk.finished
		get_tree().call_deferred("change_scene_to_file", "res://scenes/chapters/prologue/credits/prologue_end.tscn")

func _on_player_death():
	EventBus.swap_control_state.emit()
	morose.talking = true
	morose.sword.visible = false
	$Player.hearts.disable()
	$Player.player_sprite.use_parent_material = true
	var tweener = create_tween()
	tweener.tween_property($Player, "modulate", Color(0,0,0,1), 1.5)
	tweener.chain().tween_property($Player, "modulate", Color(0,0,0,0), 1.5)
	$Player/Camera2D.screen_shake(1, 3)
	await tweener.finished
	$Player.visible = false
	EventBus.swap_control_state.emit()
	DialogueManager.load_dialogue_scene("prologue_boss_wins")


func _on_boss_death():
	$Player.hearts.disable()
	$Player/Camera2D.screen_shake(2, 0)
	DialogueManager.load_dialogue_scene("prologue_boss_losses")
