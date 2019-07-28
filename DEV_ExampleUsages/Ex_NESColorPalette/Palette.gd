tool
extends Control

onready var color_vbox = $ColorVBoxContainer
onready var text_vbox = $TextVBoxContainer

func _ready():
	var color_list = NESColorPalette.COLORLIST.values()
	var color_names = NESColorPalette.COLORLIST.keys()
	var idx = 0
	
	for i in color_vbox.get_children():
		for j in i.get_children():
			j.color = color_list[idx]
			idx += 1
	
	idx = 0
	for i in text_vbox.get_children():
		for j in i.get_children():
			j.text = color_names[idx]
			(j as Label).add_color_override("font_color", color_list[idx])
			idx += 1 
