#Warp Zone (Area Detectro)
#Code by : First

#WarpZone allows player to transits into another scene (area).
#This node will be hidden in the actual game.
#When placed in the editor, you can set how teleporter works by
#picking x and y and choose target scene where the player will be
#teleported to

extends ReferenceRect

#Transition sound effect preset
enum TRANSITION_SFX {NONE, SFX_1}
onready var PRESET_TRANSITION_SFX = {
	TRANSITION_SFX.NONE : null,
	TRANSITION_SFX.SFX_1 : FJ_AudioManager.sfx_env_enter_door
}

export(String, FILE, "*.tscn") var TARGET_SCENE = 'res://Levels/'
export(Vector2) var DESTINATION = Vector2(0, 0)
export(int, "FORCED", "PLAYER INTERACTION", "DISABLED") var TELEPORT_TYPE = 0
export(bool) var PLAYER_ON_FLOOR_ONLY = false
export(String) var TRANSIT_TARGET_VIEW = "View"
export(int, "NONE", "SFX_1") var TRANSIT_SOUND_EFFECT = TRANSITION_SFX.SFX_1

#Child nodes
onready var debugger = $"/root/Debug"
onready var player = get_owner().get_node("Iterable/Player")
onready var area_notifier = $AreaNotifier

onready var global_var = $"/root/GlobalVariables"
onready var checkpoint_manager = $"/root/CheckpointManager"

#Temp variable
var is_player_in_warp_zone = false #Player's interaction checks

func _ready():
	if !Engine.is_editor_hint():
		$Label.queue_free()
	
	set_properties_references()

#Due to this inherited from area checker, all properties
#of this node must be passed to child node (area notifier
#will receive all properties from parent node.)
func set_properties_references():
	area_notifier.INTERACT_TYPE = TELEPORT_TYPE
	area_notifier.PLAYER_ON_FLOOR_ONLY = PLAYER_ON_FLOOR_ONLY

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
	#Set view target for the next scene.
	global_var.current_view = TRANSIT_TARGET_VIEW
	#Play sound
	if TRANSIT_SOUND_EFFECT != TRANSITION_SFX.NONE:
		PRESET_TRANSITION_SFX.get(TRANSIT_SOUND_EFFECT).play()
	
	get_node("/root/Level").go_to_scene(TARGET_SCENE)

func _on_AreaNotifier_entered_area() -> void:
	warp_player()
