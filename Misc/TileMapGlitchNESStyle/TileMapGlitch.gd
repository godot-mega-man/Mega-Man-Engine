#TileMapGlitch
#Code by: First

#This will glitch parent node's tilemap. Just for fun!
#Required to be placed in Level.tscn,
#otherwise, this will not work.

extends TileMap

onready var camera = get_node("/root/Level/Camera2D")
onready var parent = get_parent()

func _ready():
	if parent is TileMap:
		tile_set = parent.tile_set

func _process(delta: float) -> void:
	clear()
	if parent is TileMap:
		if camera is Camera2D:
			var cam_center = camera.get_camera_screen_center()
			for i in 17:
				var set_pos : Vector2 = cam_center + Vector2(128, -120 + (i * 16))
				var source_pos : Vector2 = cam_center + Vector2(-128, -120 + (i * 16))
				set_cellv(world_to_map(set_pos + Vector2(8, 0)),
					parent.get_cellv(parent.world_to_map(source_pos))
				)
			for i in 40:
				var set_pos : Vector2 = cam_center + Vector2(-224 + (i * 16), 112)
				var source_pos : Vector2 = cam_center + Vector2(-224 + (i * 16), -112)
				set_cellv(world_to_map(set_pos + Vector2(0, 8)),
					parent.get_cellv(parent.world_to_map(source_pos))
				)
