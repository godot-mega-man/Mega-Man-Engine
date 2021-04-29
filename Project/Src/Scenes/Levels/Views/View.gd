#Game Views
#Code by: First

# Description is missing. Please contact developer head directly.

tool
extends ReferenceRect

class_name LevelView

export (bool) var WARPS_PLAYER_AROUND_UP_DOWN := false
export (bool) var WARPS_PLAYER_LEFT_RIGHT_SIDE := false

func _ready() -> void:
	_on_View_resized()

func _on_View_resized() -> void:
	if has_node("Label"):
		get_node("Label").text = self.name
	if has_node("DebugShapeDrawer"):
		var rect_shape = RectangleShape2D.new()
		rect_shape.extents = self.rect_size
		get_node("DebugShapeDrawer").draw_using_custom_shape(false, true, self.rect_global_position, rect_shape)
