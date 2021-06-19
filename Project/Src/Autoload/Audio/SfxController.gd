# SfxController
#
# Controls whether the audio will play by conditions

extends Node


func manage_playing(audio_name : String):
	match audio_name:
		"buster_minishot":
			Audio.stop_sfx("buster_charging")
		"buster_fullshot":
			Audio.stop_sfx("buster_charging")
		"chain_end":
			Audio.stop_sfx("chain_loop")
		"cursor_sw":
			Audio.stop_sfx("buster_charging")
			Audio.stop_sfx("buster_fullshot")
		"enemy_damage":
			Audio.stop_sfx("buster")
			Audio.stop_sfx("ring_boomerang")
		"enemy_dead":
			_stop_from_enemy_dead_sound()
		"explosion2":
			_stop_from_enemy_dead_sound()
		"explosion":
			_stop_from_enemy_dead_sound()
		"powerlanding":
			Audio.stop_sfx("powerfall")
		"start":
			Audio.stop_sfx("select")
		"thunder":
			Audio.stop_sfx("shadowblade")


func manage_about_to_play(audio_name : String, sfx_order : Sfxes.SfxOrder):
	match audio_name:
		"buster":
			_try_stop_weapon_fire_sound("buster", sfx_order)
		"ring_boomerang":
			_try_stop_weapon_fire_sound("ring_boomerang", sfx_order)
		"pause":
			Audio.stop_all_sfx()
		"player_die":
			Audio.stop_all_sfx()
		


func _try_stop_weapon_fire_sound(weapon_name : String, sfx_order : Sfxes.SfxOrder):
	if not (
		Audio.is_sfx_playing("enemy_damage") or 
		Audio.is_sfx_playing("explosion") or 
		Audio.is_sfx_playing("explosion2") or 
		Audio.is_sfx_playing("enemy_dead")
	):
		return
	
	Audio.stop_sfx(weapon_name)
	sfx_order.stop = true


func _stop_from_enemy_dead_sound():
	Audio.stop_sfx("enemy_damage")
	Audio.stop_sfx("buster")
	Audio.stop_sfx("ring_boomerang")
	Audio.stop_sfx("fall")
	Audio.stop_sfx("wheel_cutter_wall")
	Audio.stop_sfx("beat")
	


func _on_Sfxes_playing(audio_name) -> void:
	manage_playing(audio_name)


func _on_Sfxes_about_to_play(audio_name, sfx_order) -> void:
	manage_about_to_play(audio_name, sfx_order)
