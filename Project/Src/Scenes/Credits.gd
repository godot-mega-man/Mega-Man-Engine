extends Node


const REWIND_MIN_POSITION = 1.0
const FAST_SCROLL_SPEED_SCALE = 15.0
const REWIND_SCROLL_SPEED_SCALE = -8.0
const DEFAULT_SCROLL_SPEED_SCALE = 1.0


func _ready() -> void:
	$ClearTime/Value.text = Playtime.get_playtime_string()
	GameHUD.hide_all()


func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_down"):
		$Anim.set_speed_scale(FAST_SCROLL_SPEED_SCALE)
	elif Input.is_action_pressed("ui_up") and $Anim.current_animation_position > REWIND_MIN_POSITION:
		$Anim.set_speed_scale(REWIND_SCROLL_SPEED_SCALE)
	else:
		$Anim.set_speed_scale(DEFAULT_SCROLL_SPEED_SCALE)
	
	_try_end_scene()


func show_clear_time():
	$ClearTime.show()
	FJ_AudioManager.sfx_ui_game_start.play()


func show_metalls():
	$CreditsVBox/Label24/MetLeft.show()
	$CreditsVBox/Label24/MetLeftHidden.hide()
	$CreditsVBox/Label24/MetRight.show()
	$CreditsVBox/Label24/MetRightHidden.hide()


func _try_end_scene():
	if not Input.is_action_just_pressed("ui_accept") or $Anim.is_playing():
		return
	
	$FadeAnim.play("Fade")
	yield($FadeAnim, "animation_finished")
	get_tree().change_scene("res://Src/Scenes/Disclaimer.tscn")


func _on_Anim_animation_finished(anim_name: String) -> void:
	if anim_name == "Anim":
		show_clear_time()
		show_metalls()
