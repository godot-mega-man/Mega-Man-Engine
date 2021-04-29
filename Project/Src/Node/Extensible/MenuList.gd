class_name MenuList extends Control


signal confirmed # Emit this by your own

signal canceled # Emit this by your own

signal closed # Emit this by your own


export var disabled : bool

var cursor_position : int


func _action_pressed(action): # Virtual method
	pass


func _on_InputActionCallback_just_pressed(action) -> void:
	if not disabled:
		_action_pressed(action)


