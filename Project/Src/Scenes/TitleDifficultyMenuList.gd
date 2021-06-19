extends MenuList


signal difficulty_selected(level)


onready var cursor_position_references = [
	$VBoxContainer/Diff1,
	$VBoxContainer/Diff2,
	$VBoxContainer/Diff3,
	$VBoxContainer/Diff4,
	$VBoxContainer/Back
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
	if action == "ui_cancel":
		emit_signal("canceled")
		Audio.sfx_ui_weapon_switch.play()


func press():
	if cursor_position >= 0 and cursor_position <= 3:
		emit_signal("difficulty_selected", cursor_position)
	if cursor_position == 4:
		emit_signal("canceled")
		Audio.play_sfx("start")
		return
	
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


func _on_TitleDifficultyMenuList_visibility_changed() -> void:
	cursor_position = 1
	_update_cursor_position()
