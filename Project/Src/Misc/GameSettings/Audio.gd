class_name GameSettingsAudio extends Node


export (float, -80, 0) var sfx_volume = 0 setget set_sfx_volume

export (float, -80, 0) var bgm_volume = 0 setget set_bgm_volume


func set_sfx_volume(val):
	sfx_volume = fposmod(val, -84)
	AudioServer.set_bus_volume_db(1, sfx_volume)


func set_bgm_volume(val):
	bgm_volume = fposmod(val, -84)
	AudioServer.set_bus_volume_db(2, bgm_volume)
