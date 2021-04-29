# Put this node inside the Player node to make the player stunned.
# The player won't be able to move or act for a short duration.
# If the player takes damage while stunned, the effect wears off.

extends Node


export var duration : float = 1.1


func _ready() -> void:
	if not get_parent() is Player:
		queue_free()
		return
	if not can_stun():
		queue_free()
		return
	
	stun(duration)


func stun(stun_time : float):
	var player : Player = get_parent()
	
	player.pf_bhv.CONTROL_ENABLE = false
	player.platformer_sprite.set_frame(14)
	player.platformer_sprite.animation_paused = true
	player.platformer_sprite.character_platformer_animation.stop()
	
	$Timer.wait_time = stun_time
	$Timer.start()
	
	player.connect("took_damage", self, "_on_Player_took_damage")


func can_stun() -> bool:
	var player : Player = get_parent()
	
	if player.is_invincible:
		return false
	if player.current_hp < 1:
		return false
	
	return true


func _on_Player_took_damage():
	var player : Player = get_parent()
	
	player.platformer_sprite.animation_paused = false
	queue_free()


func _on_Timer_timeout() -> void:
	var player : Player = get_parent()
	
	player.platformer_sprite.animation_paused = false
	player.pf_bhv.CONTROL_ENABLE = true
	queue_free()

