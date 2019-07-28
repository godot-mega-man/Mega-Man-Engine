extends ScreenTransitor

onready var sprite_ani = $Sprite/AnimationPlayer
onready var door_close_timer = $DoorCloseTimer

func _on_ScreenTransitor_transition_activated() -> void:
	sprite_ani.play("DoorOpen")
	
	#Calculates door close delay.
	var delay : float
	delay = self.start_delay + self.transit_duration.x
	
	door_close_timer.start(delay)
	
	FJ_AudioManager.sfx_env_boss_door.play()

func _on_DoorCloseTimer_timeout() -> void:
	sprite_ani.play("DoorClose")
	FJ_AudioManager.sfx_env_boss_door.play()
