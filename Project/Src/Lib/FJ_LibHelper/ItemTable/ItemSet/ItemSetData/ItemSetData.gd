# Item Set - Data

class_name ItemSetData extends Resource


export (String, FILE, "*.tres") var item

export (int) var weight : int = 10 setget _set_weight

export (int, 1, 255) var quantity : int = 1


func _init() -> void:
	weight = 10


func _set_weight(val : int):
	if val <= 0:
		val = 1
	
	weight = val
