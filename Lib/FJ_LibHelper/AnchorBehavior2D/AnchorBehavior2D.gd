# Anchor Behavior
# CR: Construct 2
# By Okanar, First
# ---------------

# The Anchor behavior is useful for automatically positioning parent objects
# relative to the window size. This is useful for supporting multiple
# screen sizes.

extends Node
class_name FJ_AnchorBehavior

# Set ctive
export(bool) var active_on_start = true setget set_active, is_active

#Child nodes
onready var player_camera = $"/root/Level/Camera2D"

#-------------------------------------------------
#       Anchor Conditions
#-------------------------------------------------

#True if the behavior is active.
func is_active() -> bool:
	return active_on_start

#-------------------------------------------------
#       Anchor Actions
#-------------------------------------------------

# Enable or disable the behavior. When disabled, the behavior does not
# affect the object at all.
func set_active(var value : bool) -> void:
	active_on_start = value

#-------------------------------------------------
#       Process
#-------------------------------------------------

#Call every in-game frame for positioning parent object.
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