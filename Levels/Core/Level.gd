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
	
	if !Engine.is_editor_hint():
		FJ_AudioManager.play_bgm(MUSIC)
	
	GameHUD.player_vital_bar.set_visible(true)
	GameHUD.boss_vital_bar.set_visible(false)

func shake_camera(duration, frequency, amplitude):
	camera.shake_camera(duration, frequency, amplitude)

#Player notifies this node that player is dead.
func _player_die():
	#Decrease coins as penalty
	currency_manager.decrease_coins_as_penalty_by_ratio(0.05)
	player.spawn_death_coins(currency_manager.coin_lost)
	death_timer.start()
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

func go_to_scene(var target):
	(fade_screen as FadeScreen).go_to_scene(target)


### SCREEN TRANSITIONS ###

func start_screen_transition():
	is_screen_transiting = true
	delete_all_objects_by_group_name("Enemy")
	delete_all_objects_by_group_name("Pickups")
	delete_all_objects_by_group_name("PlayerProjectile")
	
	#Hide boss's health bar if present
	GameHUD.boss_vital_bar.set_visible(false)

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
	player.start_screen_transition(direction, duration, reset_vel_x, reset_vel_y, 0, transit_distance)
	get_node("/root/GlobalVariables").current_view = target_view.name
	get_tree().paused = true
	yield(get_tree().create_timer(start_delay), "timeout")
	get_tree().paused = false
	yield(get_tree().create_timer(duration), "timeout")
	get_tree().paused = true
	yield(get_tree().create_timer(finish_delay), "timeout")
	get_tree().paused = false

func delete_all_objects_by_group_name(group_name : String):
	for i in get_tree().get_nodes_in_group(group_name):
		i.queue_free()
