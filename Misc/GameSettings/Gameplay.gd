extends Node

class_name GameSettingsGameplay

signal show_enemy_hp_bars_changed(enable)

export (bool) var show_enemy_hp_bars = true setget _set_show_enemy_hp_bars
export (bool) var damage_popup_player = true
export (bool) var damage_popup_enemy = true
export (bool) var exp_popup = true
export (bool) var simplified_damage_number = true
export (bool) var show_max_hp = true
export (bool) var sprite_flicker = true
export (float, 0, 1) var hp_warning_at_percentage = 0.34

func _set_show_enemy_hp_bars(new_value):
	show_enemy_hp_bars = new_value
	emit_signal("show_enemy_hp_bars_changed", new_value)