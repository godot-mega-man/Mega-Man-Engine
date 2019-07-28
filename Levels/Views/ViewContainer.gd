extends Control

class_name LevelViewContainer

#Current camera limits will be used here. THE MAIN CORE!
export var CAMERA_LIMIT_LEFT : float
export var CAMERA_LIMIT_RIGHT : float
export var CAMERA_LIMIT_TOP : float
export var CAMERA_LIMIT_BOTTOM : float
export var WARPS_OBJECTS_LEFT_RIGHT_SIDE : bool
export var WARPS_OBJECTS_AROUND_UP_DOWN : bool

export (NodePath) var default_view

var current_view : NodePath

func update_current_view(path_name_from_this_obj : String = ""):
	if path_name_from_this_obj != "" and has_node(path_name_from_this_obj):
		var node = get_node(path_name_from_this_obj)
		update_camera_limits(node)
		current_view = node.get_path()
		
		print(self.name, ": '", node.name, "' updated using saved path name.")
	elif has_node(default_view) != null:
		var node = get_node(default_view)
		update_camera_limits(node)
		current_view = node.get_path()
		
		print(self.name, ": '", node.name, "' updated using default view.")
	else:
		push_error("View does not exist! Please check what went wrong.")
	
	get_node("/root/GlobalVariables").current_view = get_node(current_view).name

func update_camera_limits(level_view):
	if level_view is LevelView:
		CAMERA_LIMIT_LEFT = level_view.get_global_rect().position.x
		CAMERA_LIMIT_TOP = level_view.get_global_rect().position.y
		CAMERA_LIMIT_RIGHT = level_view.get_global_rect().position.x + level_view.rect_size.x
		CAMERA_LIMIT_BOTTOM = level_view.get_global_rect().position.y + level_view.rect_size.y
		WARPS_OBJECTS_AROUND_UP_DOWN = level_view.WARPS_PLAYER_AROUND_UP_DOWN
		WARPS_OBJECTS_LEFT_RIGHT_SIDE = level_view.WARPS_PLAYER_LEFT_RIGHT_SIDE