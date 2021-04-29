# ScreenSizeInput (AutoLoad)
# Changes screen size by user's input at any given time. This will call a
# singleton node of ScreenSizeSetter.
#
# By default, the screen size is set at the start.

extends Node


const SIZE_1_KEY = KEY_F1
const SIZE_2_KEY = KEY_F2
const SIZE_3_KEY = KEY_F3
const SIZE_4_KEY = KEY_F4
const SIZE_FULL_SCREEN_KEY = KEY_F5


func _input(event: InputEvent) -> void:
	_change_screen_size_by_input_event(event)


func _change_screen_size_by_input_event(event : InputEvent):
	if not event.is_pressed():
		return
	
	var alt_pressed : bool
	if event is InputEventWithModifiers:
		alt_pressed = event.alt
	if alt_pressed:
		return
	
	if event is InputEventKey:
		match event.scancode:
			SIZE_1_KEY:
				GameSettings.gameplay.set_screen_scale(0)
			SIZE_2_KEY:
				GameSettings.gameplay.set_screen_scale(1)
			SIZE_3_KEY:
				GameSettings.gameplay.set_screen_scale(2)
			SIZE_4_KEY:
				GameSettings.gameplay.set_screen_scale(3)
			SIZE_FULL_SCREEN_KEY:
				ScreenSizeSetter.toggle_fullscreen()
