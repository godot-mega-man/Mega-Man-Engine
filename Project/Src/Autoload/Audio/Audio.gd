# AudioCenter (Singleton)
#
# Plays background music and sound effects.
# The main purpose of this node is to provide more control over the sound
# system that the Godot engine could not offer, such as multiple instance
# playing their audio at the same time that may lead to overlapping audios,
# leading to an increased volume, at which this node solves it by letting each
# audio plays only once.

extends Node


onready var bgm_player : BgmPlayer = $BgmPlayer
onready var sfxes : Sfxes = $Sfxes


func _ready() -> void:
	sfxes.remap_sfxes()


func play_bgm(ogg : AudioStreamOGGVorbis):
	bgm_player.play(ogg)


func stop_bgm():
	bgm_player.stop()


func play_sfx(sfx_name : String) -> AudioStreamPlayer:
	return sfxes.play(sfx_name)


func stop_sfx(sfx_name : String) -> AudioStreamPlayer:
	return sfxes.stop(sfx_name)


func stop_all_sfx():
	sfxes.stop_all()


func is_sfx_playing(sfx_name : String) -> bool:
	return sfxes.is_sfx_playing(sfx_name)
