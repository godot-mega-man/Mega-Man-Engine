extends MenuList


signal entering_start
signal entering_config
signal entering_exit


onready var cursor_position_references = [
	$VBoxContainer/Start,
	$VBoxContainer/Config,
	$VBoxContainer/Exit
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
	if cursor_position == 0:
		emit_signal("entering_start")
	if cursor_position == 1:
		emit_signal("entering_config")
	if cursor_position == 2:
		emit_signal("entering_exit")
	
	FJ_AudioManager.sfx_ui_game_start.play()


func move_cursor(direction : int):
	cursor_position += direction
	cursor_position = fposmod(cursor_position, get_menu_button_count())
	FJ_AudioManager.sfx_ui_select.play()
	_update_cursor_position()


func get_menu_button_count() -> int:
	return cursor_position_references.size()


func _update_cursor_position():
	$Cursor.rect_position.y = cursor_position_references[cursor_position].rect_position.y
