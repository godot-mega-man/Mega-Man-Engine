#Level Brightness
#Code by: First
#References: Mega Man 4 - Bright Man Stage

#This can turn the entire level's brightness on and off through
#auto-load script. To make it work, instance child scene to a
#root node of 'Level' : 

extends Node

class_name LevelBrightness

class LvBrightToggleType:
	const BLACKOUT = 0
	const BRIGHTEN = 1
	const DIM = 2

func toggle_brightness(var brightness_type : bool, var timer : float = 0.0) -> void:
	if get_node_or_null("/root/Level/LevelBrightnessModifier") == null:
		push_warning_not_instanced()
		return
	
	get_node("/root/Level/LevelBrightnessModifier").start(brightness_type, timer)

func push_warning_not_instanced():
	push_warning(str(self.get_path(), ": LevelBrightnessModifier.tscn was not instanced within /root/Level/."))