'''Debug Script'''
#CODE BY : FIRST

#DEBUG EVERYTHING. This code is always loaded into memory.
#MAKE SURE TO COMMENT EVERY LINE OF CODES WHEN DEPLOYING YOUR APP.
#CTRL+A AND THEN CTRL+K

extends Node

var is_debugging = OS.is_debug_build()

func _ready():
	if is_debugging:
		OS.window_size.x *= 2
		OS.window_size.y *= 2
		OS.center_window()
		Engine.time_scale = 1

func _input(event):
	if event is InputEventKey:
		match event.scancode:
			KEY_F1:
				OS.window_size = get_viewport().size
				OS.center_window()
			KEY_F2:
				OS.window_size = get_viewport().size * 2
				OS.center_window()
			KEY_F3:
				OS.window_size = get_viewport().size * 3
				OS.center_window()