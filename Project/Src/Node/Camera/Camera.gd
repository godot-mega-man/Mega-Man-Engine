extends Camera2D

#Follow to target node.
export (NodePath) var follow_on_path


onready var camera_shaker : CameraShaker = $CameraShaker
onready var transition_tween = $TransitionTween

onready var level := get_node_or_null("/root/Level") as Level


func _ready() -> void:
	camera_shaker.camera = self


func _process(delta):
	_move_to_target_path()


func _move_to_target_path():
	if level != null:
		if level.is_screen_transiting:
			return
	
	var all_global_positions : Array
	
	var node := get_node(follow_on_path)
	var g_pos : Vector2 #temp Global position
	if node is Node2D:
		g_pos = node.get_global_position()
	elif node is Control:
		g_pos = node.get_global_rect().position
	else:
		assert(false)
	all_global_positions.push_front(g_pos)
	
	self.global_position = all_global_positions[0]


func set_camera_limits(l, r, t, b):
	limit_left = l
	limit_right = r
	limit_top = t
	limit_bottom = b


func start_screen_transition(normalized_direction : Vector2, duration : float, start_delay : float, finish_delay : float):
	var transit_add_pos : Vector2
	var transit_add_pos_value : float
	var transit_camera_limits_property_1 := ""
	var transit_camera_limits_property_2 := ""
	
	if normalized_direction == Vector2.RIGHT:
		transit_add_pos.x = get_viewport_rect().size.x
		transit_add_pos_value = get_viewport_rect().size.x
		transit_camera_limits_property_1 = "limit_left"
		transit_camera_limits_property_2 = "limit_right"
	if normalized_direction == Vector2.LEFT:
		transit_add_pos.x = -get_viewport_rect().size.x
		transit_add_pos_value = -get_viewport_rect().size.x
		transit_camera_limits_property_1 = "limit_left"
		transit_camera_limits_property_2 = "limit_right"
	if normalized_direction == Vector2.UP:
		transit_add_pos.y = -get_viewport_rect().size.y
		transit_add_pos_value = -get_viewport_rect().size.y
		transit_camera_limits_property_1 = "limit_top"
		transit_camera_limits_property_2 = "limit_bottom"
	if normalized_direction == Vector2.DOWN:
		transit_add_pos.y = get_viewport_rect().size.y
		transit_add_pos_value = get_viewport_rect().size.y
		transit_camera_limits_property_1 = "limit_top"
		transit_camera_limits_property_2 = "limit_bottom"
	
	#Transits the camera and level camera's limits
	transition_tween.interpolate_property(
		self,
		"position",
		self.position,
		self.position + transit_add_pos,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		start_delay
	)
	transition_tween.interpolate_property(
		self,
		transit_camera_limits_property_1,
		get(transit_camera_limits_property_1),
		get(transit_camera_limits_property_1) + transit_add_pos_value,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		start_delay
	)
	transition_tween.interpolate_property(
		self,
		transit_camera_limits_property_2,
		get(transit_camera_limits_property_2),
		get(transit_camera_limits_property_2) + transit_add_pos_value,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		start_delay
	)
	#Below does nothing. It just adds up finish time
	transition_tween.interpolate_property(
		self,
		"visible",
		true,
		true,
		start_delay + duration + finish_delay,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	
	transition_tween.start()


# Returns current screen rectangle referenced by current camera's
# center position.
func get_current_screen_rect() -> Rect2:
	var cam_pos : Vector2 = get_camera_screen_center()
	var vp_rect_size = get_viewport_rect().size
	var vp_rect_half_size = Vector2(int(vp_rect_size.x) >> 1, int(vp_rect_size.y) >> 1)
	
	return Rect2(cam_pos - vp_rect_half_size, vp_rect_size)
