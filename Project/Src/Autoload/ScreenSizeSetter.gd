# ScreenSizeSetter
#
# Resposible for changing screen size. Fullscreen is also supported. You can
# also implement more screen size settings here if needed.

extends Node


signal size_changed


func set_screen_size(ratio : float):
	OS.window_size = _get_window_size_from_proj_setting() * ratio
	OS.center_window()
	
	emit_signal("size_changed")


func toggle_fullscreen():
	var on : bool = not OS.is_window_fullscreen()
	OS.set_window_fullscreen(on)


func _get_window_size_from_proj_setting() -> Vector2:
	return Vector2(
		ProjectSettings.get_setting("display/window/size/width"),
		ProjectSettings.get_setting("display/window/size/height")
	)
