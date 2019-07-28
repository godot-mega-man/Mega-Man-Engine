#Teleporter
#Code by: First

#Warp player anywhere within the scene or another scene.

tool #Tool is enabled to help visualize where the player will be.
extends Sprite

export(bool) var TELEPORT_WITHIN_SCENE = false setget update_teleport_within_scene
export(String, FILE, "*.tscn") var TARGET_SCENE = 'res://Levels/'
export(Vector2) var DESTINATION = Vector2(0, 0) setget update_destination

#Child nodes
onready var teleport_delay_timer = get_node("TeleportDelayTimer")

#Lookup node
onready var level = get_node("/root/Level")
onready var player = get_node("/root/Level/Iterable/Player") as Player
onready var checkpoint_manager = get_node("/root/CheckpointManager")
onready var audio_manager = get_node("/root/AudioManager")

#Preloading scenes
var flash_effect = preload("res://Entities/Effects/FlashScreenEffect/FlashScreenEffect.tscn")

#Getters/Setters
func update_teleport_within_scene(var value : bool) -> void:
	TELEPORT_WITHIN_SCENE = value
	_update_debug_shape_position()
func update_destination(var value : Vector2) -> void:
	DESTINATION = value
	_update_debug_shape_position()

func _update_debug_shape_position():
	if get_node_or_null("DebugShapeDrawer") != null:
		get_node("DebugShapeDrawer").draw_enabled = TELEPORT_WITHIN_SCENE
		get_node("DebugShapeDrawer").draw_using_custom_shape(true, false, DESTINATION)

#OBSOLETED
#func _draw():
#	if Engine.editor_hint:
#		if not TELEPORT_WITHIN_SCENE:
#			return
#		var draw_rect = Rect2(DESTINATION - Vector2(12, 12) - self.get_global_position(), Vector2(24, 24))
#		draw_rect(draw_rect, Color(Color.cyan), false)
#		print("Teleport destination is drawn at ", DESTINATION)

#When player activate teleporter,
#player disapears and then the game delay
#1 second before teleporting the player.
func _on_AreaNotifier_entered_area() -> void:
	player.set_player_disappear(true)
	teleport_delay_timer.start()
	
	#Play sfx
	audio_manager.sfx_teleporter.play()
	
	#Spawn Flash screen
	var effect = flash_effect.instance()
	get_parent().add_child(effect)

#Start teleporting or warping the player
#to specified target scene and x, y.
func _on_TeleportDelayTimer_timeout() -> void:
	if TELEPORT_WITHIN_SCENE:
		player.global_position = DESTINATION
		player.set_player_disappear(false)
	else:
		warp_player()

func warp_player():
	#Check for valid target scene..
	#File Checker
	var file_checker = File.new()
	#Check if target scene is valid.
	if TARGET_SCENE == null || TARGET_SCENE.empty(): #Null or empty
		push_warning(str(self) + str(name) + ': Teleportaton attempt failed! No target scene is defined.')
		return
	if file_checker.file_exists(TARGET_SCENE): #Is exist?
		if !TARGET_SCENE.get_extension() == 'tscn': #Is valid?
			push_warning(str(self) + str(name) + ': Teleportaton attempt failed! File ' + TARGET_SCENE + ' is invalid!.')
			return
	else: #Not true in every conditions
		push_warning(str(self) + str(name) + ': Teleportaton attempt failed! File ' + TARGET_SCENE + ' not found!.')
		return
	
	#Set destination
	checkpoint_manager.saved_player_position = DESTINATION
	
	level.go_to_scene(TARGET_SCENE)

#Case: on this node is moved..
func _on_Teleporter_draw() -> void:
	_update_debug_shape_position()
