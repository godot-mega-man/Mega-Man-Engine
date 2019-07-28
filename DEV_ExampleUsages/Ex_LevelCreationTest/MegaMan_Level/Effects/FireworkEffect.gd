extends Node2D

func brighten_lv():
	#Brighten the level
	var a = get_node("/root/LevelBrightness").toggle_brightness(false, 0)
