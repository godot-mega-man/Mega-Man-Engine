# Idea:
# https://megamixengine.github.io/objects/objFanUp.html

extends EnemyCore

export (float) var blow_power = 18
export (float) var max_velocity_y_allowed = 160

onready var blow_area = $BlowArea_1
onready var play_sound_area = $PlaySoundArea

var player_in_blow_area_duration : float = 0
var is_sound_playing = false

func _process(delta: float) -> void:
	var is_player_in_blow_area = false
	var is_player_in_blow_sound_area = false
	
	for i in blow_area.get_overlapping_bodies():
		if i is Player:
			if player_in_blow_area_duration == 0: #For the first time
				if i.pf_bhv.velocity.y > 0: #Only halves if the player is falling.
					i.pf_bhv.velocity.y /= 2
				play_fan_sound()
				i.is_cancel_holding_jump_allowed = false
			
			i.pf_bhv.velocity.y -= blow_power
			
			#Can't let player's velo_y exceeds limit
			#allowed by this obj.
			if i.pf_bhv.velocity.y < -max_velocity_y_allowed:
				i.pf_bhv.velocity.y = -max_velocity_y_allowed
			
			is_player_in_blow_area = true
	
	#Plays sound while in area.
	for i in play_sound_area.get_overlapping_bodies():
		if i is Player:
			is_player_in_blow_sound_area = true
	
	#Increases duration while player in the blow area.
	if is_player_in_blow_area:
		player_in_blow_area_duration += 1 * delta
	else:
		player_in_blow_area_duration = 0
	
	if not is_player_in_blow_sound_area:
		stop_fan_sound()

func play_fan_sound():
	if not FJ_AudioManager.sfx_env_fan.playing:
		FJ_AudioManager.sfx_env_fan.play()
		is_sound_playing = true

func stop_fan_sound():
	if is_sound_playing:
		if FJ_AudioManager.sfx_env_fan.is_playing():
			FJ_AudioManager.sfx_env_fan.call_deferred("stop")
			is_sound_playing = false