tool
extends Node
class_name Level

signal spawned(node)

export(bool) var CAMERA_LIMIT_ENABLE = true
export(int, -65536, 65536, 16) var CAMERA_LIMIT_LEFT = 0 setget set_camera_limit_left
export(int, -65536, 65536, 16) var CAMERA_LIMIT_TOP = 0 setget set_camera_limit_top
export(int, -65536, 65536, 16) var CAMERA_LIMIT_RIGHT = 0 setget set_camera_limit_right
export(int, -65536, 65536, 16) var CAMERA_LIMIT_BOTTOM = 0 setget set_camera_limit_bottom

export(bool) var WARPS_PLAYER_AROUND_UP_DOWN = false #Falling below the bottom of screen will instead warp player to the top.
export(bool) var WARPS_PLAYER_LEFT_RIGHT_SIDE = false #Mario style.
export(Color) var BG_COLOR = Color(0.23, 0.74, 1)
export(AudioStreamOGGVorbis) var MUSIC

#Child nodes:
onready var player = $Iterable/Player
onready var player_camera : Camera2D = player.get_node("Camera2D")
onready var death_timer = $DeathTimer
onready var fade_screen = $FadeScreen
onready var game_gui = $GameGui
onready var control_interface = $ControlInterface
onready var pause_menu_main = $PauseMenuMain

onready var checkpoint_manager = get_node_or_null("/root/CheckpointManager")
onready var currency_manager = get_node_or_null("/root/CurrencyManager")
onready var audio_manager = get_node_or_null("/root/AudioManager")
onready var player_stats = get_node_or_null("/root/PlayerStats") 

func _ready():
	set_player_camera_limits(CAMERA_LIMIT_LEFT, CAMERA_LIMIT_TOP, CAMERA_LIMIT_RIGHT, CAMERA_LIMIT_BOTTOM)
	death_timer.connect("timeout", self, '_on_death_timer_timeout')
	VisualServer.set_default_clear_color(BG_COLOR)
	debug_draw_camera()
	
	if !Engine.is_editor_hint():
		audio_manager.play_bgm(MUSIC)

func set_player_camera_limits(l, t, r, b):
	player_camera.limit_left = l
	player_camera.limit_top = t
	player_camera.limit_right = r
	player_camera.limit_bottom = b

func shake_camera(duration, frequency, amplitude):
	player_camera.shake_camera(duration, frequency, amplitude)

#Debug Draw Camera: set variable first
func set_camera_limit_left(new_value):
	CAMERA_LIMIT_LEFT = new_value
	debug_draw_camera()
func set_camera_limit_top(new_value):
	CAMERA_LIMIT_TOP = new_value
	debug_draw_camera()
func set_camera_limit_right(new_value):
	CAMERA_LIMIT_RIGHT = new_value
	debug_draw_camera()
func set_camera_limit_bottom(new_value):
	CAMERA_LIMIT_BOTTOM = new_value
	debug_draw_camera()

#Debug Draw Camera: Draw using canvasitem
func debug_draw_camera():
	if has_node("CameraLimitsDraw"):
		var rect_shape = RectangleShape2D.new()
		rect_shape.set_extents(Vector2(CAMERA_LIMIT_RIGHT - CAMERA_LIMIT_LEFT, CAMERA_LIMIT_BOTTOM - CAMERA_LIMIT_TOP))
		get_node("CameraLimitsDraw").draw_using_custom_shape(
			true,
			false,
			Vector2(CAMERA_LIMIT_LEFT, CAMERA_LIMIT_TOP),
			rect_shape
		)
		

#Player notifies this node that player is dead.
func _player_die():
	#Decrease coins and exp as penalty
	currency_manager.decrease_coins_as_penalty_by_ratio(0.05)
	player_stats.decrease_exp_as_penalty_by_ratio(0.05)
	player.spawn_death_coins(currency_manager.coin_lost)
	death_timer.start()
	#Play death sound
	audio_manager.set_all_sfx_volume(-5)
	audio_manager.sfx_player_die.play()
	player.set_player_disappear(true)
	#Hide controls GUI
	control_interface.hide_all_gui()
	get_tree().paused = false

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

func update_game_gui_exp():
	game_gui.update_exp()

func set_cut_scene_enable(enable : bool):
	if enable:
		game_gui.hide_all_gui()
		control_interface.hide_all_gui()
		player.set_control_enable_from_cutscene(true)
	else:
		game_gui.show_all_gui()
		control_interface.show_all_gui()
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
	fade_screen.dim_screen(false)
	pause_menu_main.set_pause_gui_active(false)
	game_gui.show_all_gui()
	control_interface.show_all_gui()
#When pause menu is completely closed,
#the game will then resume.
func _on_PauseMenuMain_pause_menu_closed() -> void:
	get_tree().paused = false

func _on_GameGui_inventory_btn_pressed() -> void:
	player_menu_enable()

#When inventory menu is being closed, show all gui
func _on_PlayerMenu_player_menu_being_closed() -> void:
	game_gui.show_all_gui()
	control_interface.show_all_gui()

#When the player's menu is closed completely,
#the game will then resume.
func _on_PlayerMenu_player_menu_closed() -> void:
	get_tree().paused = false

#AUTO ACTIVE (PAUSE)
#WHILE THE GAME IS NOT BEING PAUSED
#AND THE GAME LOSES FOCUS, THE GAME WILL BE
#IMMEDIATELY PAUSED AUTOMATICALLY!
func _notification(what: int) -> void:
	if Engine.is_editor_hint():
		return
	
	#If its unfocus request, then check if the game is unpaused.
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		#The game is not currently paused
		if !get_tree().paused and player.current_hp > 0:
			game_pause_enable()

func game_pause_enable():
	get_tree().paused = true
	fade_screen.dim_screen(true)
	pause_menu_main.set_pause_gui_active(true)
	game_gui.hide_all_gui()
	control_interface.hide_all_gui()

func player_menu_enable():
	get_tree().paused = true
	game_gui.hide_all_gui()
	control_interface.hide_all_gui()