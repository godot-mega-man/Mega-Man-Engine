extends Node
class_name Level

signal spawned(node)
signal transit_completed

export(Color) var BG_COLOR = Color(0.23, 0.74, 1)
export(AudioStreamOGGVorbis) var MUSIC

#Child nodes:
onready var player = $Iterable/Player
onready var camera = $Camera2D
onready var death_timer = $DeathTimer
onready var fade_screen = $FadeScreen
onready var view_container := $ViewContainer

onready var checkpoint_manager = get_node_or_null("/root/CheckpointManager")
onready var currency_manager = get_node_or_null("/root/CurrencyManager")
onready var player_stats = get_node_or_null("/root/PlayerStats") 

#Temp variables
var is_screen_transiting = false

func _ready():
	player.connect('player_die', self, '_player_die')
	death_timer.connect("timeout", self, '_on_death_timer_timeout')
	VisualServer.set_default_clear_color(BG_COLOR)
	
	#Update view and camera limits
	view_container.update_current_view(get_node("/root/GlobalVariables").current_view)
	camera.set_camera_limits(
		view_container.CAMERA_LIMIT_LEFT,
		view_container.CAMERA_LIMIT_RIGHT,
		view_container.CAMERA_LIMIT_TOP,
		view_container.CAMERA_LIMIT_BOTTOM
	)
	
	GameHUD.player_vital_bar.set_visible(false)
	GameHUD.boss_vital_bar.set_visible(false)
	GameHUD.update_life()
	Playtime.start()
	FJ_AudioManager.play_bgm(MUSIC)
	
	_try_refill_player_ammo()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and event.scancode == KEY_ESCAPE:
			pause_game()


func pause_game():
	if not player.is_processing():
		return
	if not player.pf_bhv.CONTROL_ENABLE:
		return
	if player.is_cutscene_mode:
		return
	if is_screen_transiting:
		return
	
	FJ_AudioManager.sfx_ui_pause.play()
	FJ_AudioManager.sfx_combat_buster_charging.stop()
	FJ_AudioManager.sfx_env_chain_loop.stop()
	
	$PauseMenu.show_pause_menu()
	get_tree().paused = true


func go_to_scene(var target):
	(fade_screen as FadeScreen).go_to_scene(target)


func start_screen_transition():
	is_screen_transiting = true
	delete_all_objects_by_group_name("Enemy")
	delete_all_objects_by_group_name("Pickups")
	delete_all_objects_by_group_name("PlayerProjectile")
	
	#Hide boss's health bar if present
	GameHUD.boss_vital_bar.set_visible(false)



func init_screen_transition(direction : Vector2, duration : float, target_view, reset_vel_x : bool, reset_vel_y : bool, start_delay : float, finish_delay : float, transit_distance : float) -> void:
	start_screen_transition()
	camera.start_screen_transition(direction, duration, start_delay, finish_delay)
	player.start_screen_transition(direction, duration, reset_vel_x, reset_vel_y, start_delay, transit_distance)
	get_node("/root/GlobalVariables").current_view = target_view.name
	
	get_tree().paused = true
	yield(get_tree().create_timer(start_delay), "timeout")
	get_tree().paused = false


func delete_all_objects_by_group_name(group_name : String):
	for i in get_tree().get_nodes_in_group(group_name):
		i.queue_free()


func begin_victory_process():
	$VictoryStartTimer.start()


func victory():
	player.platformer_sprite.is_sliding = false
	player.pf_bhv.velocity.y = -50
	player.is_sliding = false
	player.slide_remaining = -10
	player.set_control_enable(false)
	player.is_cutscene_mode = true
	Playtime.stop()
	
	if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
		FJ_AudioManager.play_bgm(preload("res://Assets/Sounds/Bgm/victory_epic.ogg"))
	else:
		FJ_AudioManager.play_bgm(preload("res://Assets/Sounds/Bgm/victory.ogg"))
	
	yield(get_tree().create_timer(4.0), "timeout")
	player.teleport_out()
	yield(get_tree().create_timer(1.0), "timeout")
	
	if Difficulty.difficulty < Difficulty.DIFF_NORMAL:
		go_to_scene("res://Src/Scenes/WeaponGet.tscn")
	else:
		go_to_scene("res://Src/Scenes/Credits.tscn")


func _try_refill_player_ammo():
	if Difficulty.difficulty == Difficulty.DIFF_NEWCOMER:
		GameHUD.player_weapon_bar.frame = 28
	if Difficulty.difficulty == Difficulty.DIFF_CASUAL:
		if GameHUD.player_weapon_bar.frame < 21:
			GameHUD.player_weapon_bar.frame = 21
	if Difficulty.difficulty == Difficulty.DIFF_NORMAL:
		if GameHUD.player_weapon_bar.frame < 14:
			GameHUD.player_weapon_bar.frame = 14
	if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
		if GameHUD.player_weapon_bar.frame < 7:
			GameHUD.player_weapon_bar.frame = 7


# Player notifies this node that player is dead.
func _player_die():
	death_timer.start()
	get_node("/root/GlobalVariables").current_view = get_node("/root/CheckpointManager").saved_view_name
	
	if Difficulty.difficulty > Difficulty.DIFF_NEWCOMER:
		Life.lose_one_life()


func _on_TransitionTween_tween_all_completed() -> void:
	is_screen_transiting = false
	#Update view container to current. And camera too.
	view_container.update_current_view(get_node("/root/GlobalVariables").current_view)
	camera.set_camera_limits(
		view_container.CAMERA_LIMIT_LEFT,
		view_container.CAMERA_LIMIT_RIGHT,
		view_container.CAMERA_LIMIT_TOP,
		view_container.CAMERA_LIMIT_BOTTOM
	)
	emit_signal("transit_completed")
	
	#Call all on-screen ObjSpawner to spawn obj right away (OnScreen enabled only).
	get_tree().call_group("ObjSpawner", "spawn_object")
	
	get_tree().paused = false


# When death timer runs out, the game will
# roll back to last checkpoint (position and target scene).
func _on_death_timer_timeout():
	if Life.is_game_over():
		fade_screen.go_to_scene("res://Src/Scenes/GameOver.tscn")
	else:
		fade_screen.go_to_scene(checkpoint_manager.get_current_checkpoint_target_scene())



func _on_VictoryStartTimer_timeout() -> void:
	victory()


func _on_LevelPauseMenuList_selected(id) -> void:
	if id == 0:
		$PauseMenu.hide_pause_menu()
		yield($PauseMenu, "menu_hidden")
		get_tree().paused = false
	if id == 1:
		$PauseMenu.enclose_pause_menu()
		yield($PauseMenu, "menu_enclosed")
		get_tree().paused = false
		GameHUD.hide_all()
		fade_screen.go_to_scene("res://Src/Scenes/Title.tscn")
	if id == 2:
		$PauseMenu.enclose_pause_menu()
		yield($PauseMenu, "menu_enclosed")
		get_tree().quit()
