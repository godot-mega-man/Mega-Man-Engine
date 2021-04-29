extends EnemyCore

var stop : bool # If true, stops as soon as this obj spawned
var view_container : NodePath
var new_level_view : NodePath

func _ready() -> void:
	if stop:
		stop()
	else:
		start()
	
	if not view_container.is_empty() and not new_level_view.is_empty():
		var _vc = get_node(view_container)
		var _v = get_node(new_level_view)
		
		get_node("/root/GlobalVariables").current_view = _v.get_path()
		_vc.update_current_view(get_node("/root/GlobalVariables").current_view)
		get_camera().set_camera_limits(
			_vc.CAMERA_LIMIT_LEFT,
			_vc.CAMERA_LIMIT_RIGHT,
			_vc.CAMERA_LIMIT_TOP,
			_vc.CAMERA_LIMIT_BOTTOM
		)
	
	queue_free()

func start():
	get_tree().call_group("ChainTilemap", "start")

func stop():
	get_tree().call_group("ChainTilemap", "stop")

func get_camera() -> Camera2D:
	for i in get_tree().get_nodes_in_group("CameraCustom"):
		if i is Camera2D:
			return i
	
	return null
