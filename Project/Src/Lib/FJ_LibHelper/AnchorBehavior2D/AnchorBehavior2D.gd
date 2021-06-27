# Anchor Behavior
#
# The Anchor behavior automatically positions parent objects
# relative to the window size. This is useful for supporting multiple
# screen sizes.

class_name FJ_AnchorBehavior extends Node


export var active_on_start : bool = true setget set_active, is_active


onready var player_camera = $"/root/Level/Camera2D"


func _process(delta: float) -> void:
	if not is_active():
		return
	
	var _parent = get_parent()
	if _parent is Node2D:
		var ui_position = player_camera.get_camera_screen_center()
		ui_position -= get_viewport().get_visible_rect().size / 2
		_parent.global_position = ui_position
	if _parent is Control:
		var ui_position = player_camera.get_camera_screen_center()
		ui_position -= get_viewport().get_visible_rect().size / 2
		_parent.rect_global_position = ui_position


func is_active() -> bool:
	return active_on_start


func set_active(var value : bool) -> void:
	active_on_start = value
