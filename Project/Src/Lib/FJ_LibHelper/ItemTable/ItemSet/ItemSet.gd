#Item Set

tool
class_name ItemSet extends Node


export (Array, Resource) var items : Array setget _set_items


func _set_items(val):
	items = val
	
	_replace_last_with_empty_item_set_data()


func _replace_last_with_empty_item_set_data():
	if items.size() == 0:
		return
	
	#If at the end of an array is empty, we replace
	#empty one with a new ItemSetData.
	if items.back() == null:
		items.remove(items.size() - 1)
		var new_item_set_data = ItemSetData.new()
		items.append(new_item_set_data)


func get_an_item():
	if items.size() == 0:
		return null
	
	var overall_weight : int
	for i in items:
		if i is ItemSetData:
			overall_weight += i.weight
	
	var val = randi() % overall_weight + 1
	
	var _temp_current := 0
	for i in items:
		if i is ItemSetData:
			if within_numbers(val, _temp_current + 1, _temp_current + i.weight):
				return i
			_temp_current += i.weight
	
	return null


func within_numbers(val : int, min_val : int, max_val : int) -> bool:
	return val >= min_val && val <= max_val
