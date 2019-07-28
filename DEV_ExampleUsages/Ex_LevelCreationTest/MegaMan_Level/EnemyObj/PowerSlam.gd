extends EnemyCore

export (float) var attack_range = 8
export (float) var float_up_speed = 120

onready var sprite_ani = $SpriteMain/Sprite/Ani
onready var pf_bhv = $PlatformBehavior

var is_hover_attacking = false

func _process(delta: float) -> void:
	#Stomps when nearby player.
	if is_hover_attacking:
		pf_bhv.velocity.y = -float_up_speed
		
		pf_bhv.simulate_walk_left = sprite_main.scale.x == 1
		pf_bhv.simulate_walk_right = !sprite_main.scale.x == 1
		
		if within_player_range(attack_range):
			initiate_stomping_process()
	else:
		pf_bhv.simulate_walk_left = false
		pf_bhv.simulate_walk_right = false

func initiate_stomping_process():
	is_hover_attacking = false
	sprite_ani.play("Stomping")
	pf_bhv.velocity = Vector2()

func hover_forward():
	FJ_AudioManager.sfx_combat_power_launch.play()
	sprite_ani.play("Hovering")
	is_hover_attacking = true

#Sets fallspeed to max
func stomp():
	FJ_AudioManager.sfx_combat_power_fall.play()
	set_fall_speed_to_max()

func set_fall_speed_to_max():
	pf_bhv.velocity.y = pf_bhv.MAX_FALL_SPEED

func _on_PlatformBehavior_landed() -> void:
	sprite_ani.play("Landing")
	
	#Stops falling sound
	FJ_AudioManager.sfx_combat_power_fall.call_deferred("stop")
	
	FJ_AudioManager.sfx_combat_power_landing.play()

func finish_landing():
	sprite_ani.play("Launch")

func _on_PlatformBehavior_hit_ceiling() -> void:
	initiate_stomping_process()
