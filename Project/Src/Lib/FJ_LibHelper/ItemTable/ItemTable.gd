#Item Table

tool
class_name ItemTable extends Node


export (bool) var enabled = true


func get_items() -> Array:
	if not enabled:
		return []
	
	var arr := []
	
	for i in get_children():
		if i is ItemSet:
			arr.push_back(i.get_an_item())
	
	return arr
