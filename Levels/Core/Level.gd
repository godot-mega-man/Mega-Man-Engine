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
onready var game_gui = $GameGui
onready var view_container := $ViewContainer
onready var boss_health_bar := $BossHealthBar as BossHealthBar

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
	
	if !Engine.is_editor_hint():
		FJ_AudioManager.play_bgm(MUSIC)

func shake_camera(duration, frequency, amplitude):
	camera.shake_camera(duration, frequency, amplitude)

#Player notifies this node that player is dead.
func _player_die():
	#Decrease coins as penalty
	currency_manager.decrease_coins_as_penalty_by_ratio(0.05)
	player.spawn_death_coins(currency_manager.coin_lost)
	death_timer.start()
	FJ_AudioManager.stop_bgm()
	#Hide controls GUI
	#Load last saved view
	print('Level:_player_die() : View updated with saved checkpoint.')
	get_node("/root/GlobalVariables").current_view = get_node("/root/CheckpointManager").saved_view_name

#When death timer runs out, the game will
#roll back to last checkpoint (position and target scene).
#Everything will be paused.
func _on_death_timer_timeout():
#	game_gui.hide_all_gui()
#	death_screen_gui.start_death_gui()
#	get_tree().paused = true
	fade_screen.go_to_scene(checkpoint_manager.get_current_checkpoint_target_scene())

#Callback from DeathScreenGUI. 
#When respawn button is pressed.
#Respawn at last checkpoint
func _on_DeathScreenGUI_respawn_btn_pressed() -> void:
	fade_screen.go_to_scene(checkpoint_manager.get_current_checkpoint_target_scene())

#Callback from DeathScreenGUI. 
#When to village button is pressed.
#Respawn to nearest village 
func _on_DeathScreenGUI_to_village_btn_pressed() -> void:
	#HARD_CODED!
	checkpoint_manager.clear_checkpoint()
	fade_screen.go_to_scene("res://Levels/Lv_TestLarge.tscn")

func go_to_scene(var target):
	(fade_screen as FadeScreen).go_to_scene(target)

func update_game_gui_health():
	game_gui.update_gui_bar()

func update_game_gui_coin():
	game_gui.update_coin()

func update_game_gui_diamond():
	game_gui.update_diamond()

func set_cut_scene_enable(enable : bool):
	if enable:
		game_gui.hide_all_gui()
		player.set_control_enable_from_cutscene(true)
	else:
		game_gui.show_all_gui()
		player.set_control_enable_from_cutscene(false)
	
	player.set_control_enable(!enable)

#When the pause button is pressed, the game is
#temporarity paused.
#Hide player's hud and on-screen controls.
#The screen will dim
func _on_GameGui_pause_btn_pressed() -> void:
	game_pause_enable()

#From pause menu main, when the resume button button is pressed,
#show player's hud and on-screen controls normally.
#The screen will brightern
func _on_PauseMenuMain_resume_btn_pressed() -> void:
	game_gui.show_all_gui()
#When pause menu is completely closed,
#the game will then resume.
func _on_PauseMenuMain_pause_menu_closed() -> void:
	get_tree().paused = false

#When the inventory button is pressed, show its GUI.
func _on_GameGui_inventory_btn_pressed() -> void:
	player_menu_enable()

#When inventory menu is being closed, show all gui
func _on_PlayerMenu_being_closed() -> void:
	game_gui.show_all_gui()

#When the player's menu is closed completely,
#the game will then resume.
func _on_PlayerMenu_closed() -> void:
	get_tree().paused = false

#AUTO ACTIVE (PAUSE)
#WHILE THE GAME IS NOT BEING PAUSED
#AND THE GAME LOSES FOCUS, THE GAME WILL BE
#IMMEDIATELY PAUSED AUTOMATICALLY!
#func _notification(what: int) -> void:
#	if Engine.is_editor_hint():
#		return
#
#	#If its unfocus request, then check if the game is unpaused.
#	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
#		#The game is not currently paused
#		if !get_tree().paused and player.current_hp > 0:
#			game_pause_enable()

func game_pause_enable():
	get_tree().paused = true
	game_gui.hide_all_gui()

func player_menu_enable():
	get_tree().paused = true
	game_gui.hide_all_gui()

### SCREEN TRANSITIONS ###

func start_screen_transition():
	is_screen_transiting = true
	delete_all_enemies()

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
	get_tree().call_group("ObjSpawner", "_on_SpawnRange_screen_entered")

func init_screen_transition(direction : Vector2, duration : float, target_view, reset_vel_x : bool, reset_vel_y : bool, start_delay : float, finish_delay : float, transit_distance : float) -> void:
	start_screen_transition()
	camera.start_screen_transition(direction, duration, start_delay, finish_delay)
	player.start_screen_transition(direction, duration, reset_vel_x, reset_vel_y, start_delay, transit_distance)
	get_node("/root/GlobalVariables").current_view = target_view.name

func delete_all_enemies():
	for i in get_tree().get_nodes_in_group("Enemy"):
		i.queue_free()
