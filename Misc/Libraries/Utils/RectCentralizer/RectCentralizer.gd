#Rect Centralizer
#Code by: First

#This object helps resizing the rect's size by the value of rect's position. 
#Useful for VisibilityNotifier's rect, and others.

extends Node

class_name RectCentralizer

#Sets rect's size to match its position. The size of rect will become negative. 
static func center_rect_by_x_y(var vector2 : Vector2) -> Rect2:
	return Rect2(-vector2, vector2 * 2)
static func center_rect_by_value(var f : float) -> Rect2:
	return Rect2(Vector2(f, f), Vector2(f, f) * 2)

#Set position by rect2. 
#This is useful for setting Node2D's position depends on the rect's size. 
static func set_position_by_rect(var rect : Rect2) -> Vector2:
	return -rect.size