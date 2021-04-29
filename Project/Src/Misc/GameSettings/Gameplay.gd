extends Node


class_name GameSettingsGameplay


const MAX_SCREEN_SIZES = 6


signal screen_scale_changed


export (bool) var fullscreen = false

export (bool) var damage_popup_player = true

export (bool) var damage_popup_enemy = true

export (bool) var sprite_flicker = true setget set_sprite_flicker

export (bool) var nes_slowdown = false setget set_nes_slowdown

export (int) var screen_scale = 2 setget set_screen_scale


func set_screen_scale(val):
	screen_scale = fposmod(val, MAX_SCREEN_SIZES)
	
	ScreenSizeSetter.set_screen_size(screen_scale + 1)
	emit_signal("screen_scale_changed")


func set_sprite_flicker(val):
	sprite_flicker = val
	
	if not sprite_flicker:
		nes_slowdown = false


func set_nes_slowdown(val):
	nes_slowdown = val
	
	if not sprite_flicker:
		sprite_flicker = true
