#Reference: New Super Mario Bros (DS), World 8-Tower2
#A limiter of camera bottom limit that increases while the camera
#goes up beyonds offset.
#Works best on vertical level.

extends EnemyCore

export (float) var distance = 224 #Offset at which the camera bottom limit changes
 
onready var camera : CameraCustom

func _ready():
	init_find_camera()

func _process(delta):
	if camera == null:
		return
	
	var cam_pos_y = camera.get_camera_position().y
	
	if cam_pos_y < camera.limit_bottom - distance:
		camera.limit_bottom = cam_pos_y + distance

func init_find_camera():
	#Find a camera by group name lookup.
	var cam_obj = get_tree().get_nodes_in_group("CameraCustom").back()
	
	if cam_obj is CameraCustom:
		camera = cam_obj
