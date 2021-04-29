extends Node


func reset():
	_clear_saved_checkpoints()
	_stop_reset_playtime()
	_reset_lives()


func _clear_saved_checkpoints():
	CheckpointManager.clear_checkpoint()
	GlobalVariables.current_view = ""
	GameHUD.player_weapon_bar.frame = 28
	Life.reset()
	get_node("/root/PlayerStats").restore_hp_on_load = true


func _stop_reset_playtime():
	Playtime.stop()
	Playtime.reset()


func _reset_lives():
	Life.reset()
