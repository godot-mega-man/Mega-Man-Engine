extends ReferenceRect

signal resume_btn_pressed
signal game_setting_btn_pressed
signal return_to_map_btn_pressed
signal main_menu_btn_pressed
signal quit_game_btn_pressed
signal pause_menu_closed

export (float) var rect_y_offset = 0

#Child nodes
onready var resume_button = $VBoxContainer/VBoxContainer/ResumeButton
onready var show_hide_player = $ShowHidePlayer

const ORIGIN_POSITION_Y = 0

func _process(delta: float) -> void:
	self.rect_position.y = ORIGIN_POSITION_Y + rect_y_offset

func set_all_button_enable(var set : bool):
	resume_button.disabled = !set

#When resume button is pressed... The game should resume!
func _on_ResumeButton_pressed() -> void:
	emit_signal("resume_btn_pressed")

func _on_ShowHidePlayer_animation_finished(anim_name: String) -> void:
	if anim_name == 'Hide':
		emit_signal("pause_menu_closed")
