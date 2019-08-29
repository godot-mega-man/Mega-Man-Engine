extends Camera2D

class_name CameraCustom

#Follow to target node when there is at least one.
#If there are 2 or more, the camera will use relative path to
#all adjacent node's position. 
export (Array, NodePath) var follow_on_paths

#Child nodes
onready var transition_tween = $TransitionTween

onready var level := get_node_or_null("/root/Level") as Level

var _duration = 0.0
var _period_in_ms = 0.0
var _amplitude = 0.0
var _timer = 0.0
var _last_shook_timer = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _last_offset = Vector2(0, 0)

func _ready():
	
	set_process(true)

# Shake with decreasing intensity while there's time remaining.
func _process(delta):
	_camera_shake_process(delta)
	_move_to_target_paths_positions()

func _camera_shake_process(delta : float):
	# Only shake when there's shake time remaining.
	if _timer == 0:
		return
	# Only shake on certain frames.
	_last_shook_timer = _last_shook_timer + delta
	# Be mathematically correct in the face of lag; usually only happens once.
	while _last_shook_timer >= _period_in_ms:
		_last_shook_timer = _last_shook_timer - _period_in_ms
		# Lerp between [amplitude] and 0.0 intensity based on remaining shake time.
		var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
		# Noise calculation logic from http://jonny.morrill.me/blog/view/14
		var new_x = rand_range(-1.0, 1.0)
		var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
		var new_y = rand_range(-1.0, 1.0)
		var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
		_previous_x = new_x
		_previous_y = new_y
		# Track how much we've moved the offset, as opposed to other effects.
		var new_offset = Vector2(x_component, y_component)
		set_offset(get_offset() - _last_offset + new_offset)
		_last_offset = new_offset
	# Reset the offset when we're done shaking.
	_timer = _timer - delta
	if _timer <= 0:
		_timer = 0
		set_offset(get_offset() - _last_offset)

#Move the camera to target path every in-game frame.
#############CURRENTLY SUPPORTS ONLY ONE NODE...##############
func _move_to_target_paths_positions():
	if level != null:
		if level.is_screen_transiting:
			return
	
	var all_global_positions : Array
	for i in follow_on_paths:
		var node := get_node(i)
		var g_pos : Vector2 #temp Global position
		if node is Node2D:
			g_pos = node.get_global_position()
		elif node is Control:
			g_pos = node.get_global_rect().position
		else:
			assert(false)
		all_global_positions.push_front(g_pos)
	
	self.global_position = all_global_positions[0]

# Kick off a new screenshake effect.
func shake_camera(duration, frequency, amplitude):
	return
	#Only shake if new duration is greater than current duration.
	if not duration > _timer:
		return
	
	# Initialize variables.
	_duration = duration
	_timer = duration
	_period_in_ms = 1.0 / frequency
	_amplitude = amplitude
	_previous_x = rand_range(-1.0, 1.0)
	_previous_y = rand_range(-1.0, 1.0)
	# Reset previous offset, if any.
	set_offset(get_offset() - _last_offset)
	_last_offset = Vector2(0, 0)

func set_camera_limits(l, r, t, b):
	limit_left = l
	limit_right = r
	limit_top = t
	limit_bottom = b

# Finish delay used in last call method:
# transition_tween.interpolate_property(...)
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
	
	#Transits the camera, level camera's limits
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
	#Below does nothing, just for adds up finish time purposes.
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