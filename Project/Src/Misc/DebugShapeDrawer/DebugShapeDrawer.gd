tool
extends Node2D

export (bool) var draw_enabled = true setget _set_draw_enabled
export (Shape2D) var sampling_shape : Shape2D setget _set_sampling_shape
export (Color) var draw_color : Color = Color(1,1,1) setget _set_draw_color
export (bool) var filled = false setget _set_filled
export (bool) var centered = true setget _set_centered
export (float, 1, 64) var draw_width : float = 1 setget _set_draw_width

var temp_draw_position : Vector2
var position_relative_to_this : bool = false
var position_relative_initial : Vector2

#Getter/setters
func _set_draw_enabled(new_value):
	draw_enabled = new_value
	update()
func _set_sampling_shape(new_value):
	if !Engine.is_editor_hint():
		return
	if !_is_supported(new_value):
		push_error(str(new_value, " is not supported yet!"))
		return
	sampling_shape = new_value
	connect_sampling_shape_callback()
	update()
func _set_draw_color(new_value):
	draw_color = new_value
	update()
func _set_filled(new_value):
	filled = new_value
	update()
func _set_centered(new_value):
	centered = new_value
	update()
func _set_draw_width(new_value):
	draw_width = new_value
	update()

#Draw using custom shape.
# @param set_new_position : If true, new position of this method will be set. 
# @param draw_position : This will set its value.
func draw_using_custom_shape(var set_new_position : bool, var use_relative_position, var draw_position : Vector2 = Vector2(0, 0), var new_shape = null) -> void:
	if !Engine.is_editor_hint():
		return
	
	if set_new_position:
		self.temp_draw_position = draw_position
	
	if use_relative_position:
		position_relative_initial = self.position
	else:
		if is_inside_tree():
			position_relative_initial = Vector2(0, 0) - global_position
		else:
			position_relative_initial = Vector2(0, 0)
	
	if new_shape != null:
		sampling_shape = new_shape
	
	update()

func _draw():
	if !draw_enabled:
		return
	if sampling_shape is RectangleShape2D:
		#Do casting object to its type
		sampling_shape = sampling_shape as RectangleShape2D
		
		#Add offset if center variable is checked
		var offset : Vector2
		if centered:
			offset = sampling_shape.extents / 2
		
		#If filled is on, width will not be used.
		if filled:
			draw_rect(
				Rect2(
					position_relative_initial + temp_draw_position - offset,
					sampling_shape.extents
					),
				draw_color,
				filled
			)
		else:
			draw_line(
				position_relative_initial + temp_draw_position - offset,
				position_relative_initial + temp_draw_position - offset + Vector2(sampling_shape.extents.x, 0),
				draw_color,
				draw_width
			)
			draw_line(
				position_relative_initial + temp_draw_position - offset,
				position_relative_initial + temp_draw_position - offset + Vector2(0, sampling_shape.extents.y),
				draw_color,
				draw_width
			)
			draw_line(
				position_relative_initial + temp_draw_position - offset + sampling_shape.extents,
				position_relative_initial + temp_draw_position - offset + Vector2(0, sampling_shape.extents.y),
				draw_color,
				draw_width
			)
			draw_line(
				position_relative_initial + temp_draw_position - offset + sampling_shape.extents,
				position_relative_initial + temp_draw_position - offset + Vector2(sampling_shape.extents.x, 0),
				draw_color,
				draw_width
			)
			
	if sampling_shape is CircleShape2D:
		#Do casting object to its type
		sampling_shape = sampling_shape as CircleShape2D
		
		#Add offset if center variable is checked
		var offset : Vector2
		if !centered:
			offset = Vector2(sampling_shape.radius, sampling_shape.radius)
		
		draw_circle(
			position_relative_initial + temp_draw_position + offset,
			sampling_shape.radius,
			draw_color
		)
	if sampling_shape is SegmentShape2D:
		#Do casting object to its type
		sampling_shape = sampling_shape as SegmentShape2D
		
		draw_line(
			position_relative_initial + temp_draw_position + sampling_shape.a,
			position_relative_initial + temp_draw_position + sampling_shape.b,
			draw_color,
			draw_width
		)

func _ready():
	if sampling_shape != null:
		connect_sampling_shape_callback()
	
	draw_using_custom_shape(false, false)

func connect_sampling_shape_callback():
	var new_method_name : String = "_on_sampling_shape_changed"
	if sampling_shape != null:
		if !sampling_shape.is_connected("changed", self, new_method_name):
			sampling_shape.connect("changed", self, new_method_name)

func _on_sampling_shape_changed():
	update()

func _is_supported(what) -> bool:
	if what == null:
		return true
	#Below is WHAT we don't support.
	if (
		what is CapsuleShape2D or
		what is ConcavePolygonShape2D or
		what is ConvexPolygonShape2D or
		what is RayShape2D or
		what is LineShape2D
	):
		return false
	return true
