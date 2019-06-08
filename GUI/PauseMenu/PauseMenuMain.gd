extends CanvasLayer

signal resume_btn_pressed
signal game_setting_btn_pressed
signal return_to_map_btn_pressed
signal main_menu_btn_pressed
signal quit_game_btn_pressed
signal pause_menu_closed

#Child nodes
onready var pause_menu_container = $Control/PauseMenuContainer

#Receives response from pause menu that
#the game is resumed
func _on_PauseMenuContainer_resume_btn_pressed() -> void:
	set_pause_gui_active(false)
	emit_signal("resume_btn_pressed")

func set_pause_gui_active(var set : bool) -> void:
	if set:
		pause_menu_container.show_hide_player.play("Show")
	else:
		pause_menu_container.show_hide_player.play("Hide")

func _on_PauseMenuContainer_pause_menu_closed() -> void:
	emit_signal("pause_menu_closed")
