extends ReferenceRect
class_name ChainDestroyerArea

#Lookup node (preload)
onready var audio_manager = get_node("/root/AudioManager")
enum SFX{
	NONE,
	ENEMY_COLLAPSE
}
onready var sfx_preset = {
	SFX.NONE : null,
	SFX.ENEMY_COLLAPSE : audio_manager.sfx_enemy_collapse
}

export(float, 0, 60, 0.001) var destroy_delay = 0.1
export(bool) var shake_screen = true
export(float, 0.01, 1) var shake_duration = 0.3
export(float) var shake_frequency = 50
export(float, 0.1, 100) var shake_strength = 3
export(int, -1, 65535) var set_tile_id = -1
export(bool) var update_nearby_tiles_bitmap = true
export(PackedScene) var create_effect = preload("res://Entities/Effects/Explosion/Explosion.tscn")
export(PackedScene) var destroy_effect = preload("res://Entities/Effects/Explosion/Explosion.tscn")
export(SFX) var sfx = 1

#Child nodes

#Lookup node
onready var tile_map
onready var level_iterable = get_node("/root/Level/Iterable")
onready var player = get_node("/root/Level/Iterable/Player")
onready var player_camera = get_node("/root/Level/Iterable/Player/Camera2D")

#Temp variables
var is_any_effect_on_screen : bool = false #True when any of effect is visible on screen.

func _ready():
	assign_tile_map_to_modify()

#This will let destroyer know which tilemap to destroy
#according to parent (ChainDestroyController)'s determination
#of which tilemap will be used.
func assign_tile_map_to_modify():
	var DEFAULT_TILE_MAP = get_node("/root/Level/TileMap")
	var tile_map_node_path = get_parent().tile_map_to_modify
	
	#If ChainDestroyController not assign tilemap nodepath,
	#default path will be used.
	if tile_map_node_path.is_empty():
		tile_map = DEFAULT_TILE_MAP
	else:
		tile_map = get_parent().get_node(tile_map_node_path)

func _destroy_blocks():
	#Now, destroy blocks!
	#Depends on the size of its destroyer, I(ChainDestroyerArea) am going to
	#iterate through my rect_size. If my size, for example, is 32x and 16y,
	#I will loop and destroy 2 times in total.
	
	#First, loop through x log y
	for i in int(self.rect_size.x / 16):
		for j in int(self.rect_size.y / 16):
			var current_position = (self.get_global_position() + Vector2(i * 16, j * 16))
			var tile_target = current_position / 16
			#Destroy Tile
			tile_map.call_deferred("set_cellv", tile_target, set_tile_id)
			if update_nearby_tiles_bitmap:
				tile_map.call_deferred("update_bitmask_area", tile_target)
			tile_map.call_deferred("update_dirty_quadrants")
			
			#Create Explosion Effect and set position-
			#related to current loop_iterating x,y.
			var can_create_effect : bool = false
			if set_tile_id == -1 and destroy_effect != null:
				can_create_effect = true
			if set_tile_id != -1 and create_effect != null:
				can_create_effect = true
			if can_create_effect:
				var effect 
				if set_tile_id == -1:
					effect = destroy_effect.instance()
				else:
					effect = create_effect.instance()
				level_iterable.add_child(effect)
				effect.set_global_position(current_position)
				effect.global_position += Vector2(8, 8) #Shifting
				
				if !is_any_effect_on_screen:
					is_any_effect_on_screen = is_position_visible_within_camera(current_position, player_camera)
	
	#Play sound effect and shake camera if any of effect is visible on screen.
	if is_any_effect_on_screen:
		if sfx != SFX.NONE:
			sfx_preset[sfx].play()
		if shake_screen:
			player_camera.shake_camera(shake_duration, shake_frequency, shake_strength)

func is_position_visible_within_camera(var pos : Vector2, var current_camera : Camera2D) -> bool:
	var p_cam_pos = current_camera.get_camera_position()
	var vp_rect = get_viewport_rect().size
	var vp_rect_half_size_x = int(vp_rect.x) >> 1
	var vp_rect_half_size_y = int(vp_rect.y) >> 1
	
	return Rect2(Vector2(p_cam_pos.x - vp_rect_half_size_x, p_cam_pos.y - vp_rect_half_size_y), vp_rect).has_point(pos)

