extends MenuList


signal selected(id)


onready var cursor_position_references = [
	$VBoxContainer/Retry,
	$VBoxContainer/Title
]


func _ready() -> void:
	_update_cursor_position()


func _action_pressed(action): # Overrides
	if action == "ui_up":
		move_cursor(-1)
	if action == "ui_down":
		move_cursor(1)
	if action == "ui_accept":
		press()


func press():
	emit_signal("selected", cursor_position)
	Audio.play_sfx("start")


func move_cursor(direction : int):
	cursor_position += direction
	cursor_position = fposmod(cursor_position, get_menu_button_count())
	Audio.play_sfx("select")
	_update_cursor_position()


func get_menu_button_count() -> int:
	return cursor_position_references.size()


func _update_cursor_position():
	$Cursor.rect_position.y = cursor_position_references[cursor_position].rect_position.y
