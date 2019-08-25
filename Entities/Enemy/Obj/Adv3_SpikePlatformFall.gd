extends EnemyCore

onready var pf_bhv = $PlatformBehavior
onready var detect_area = $DetectArea2D
onready var fall_delay_timer = $FallDelayTimer
onready var sprite_ani = $SpriteMain/Ani
onready var respawn_timer = $RespawnTimer
onready var respawn_ready_timer = $RespawnReadyTimer

#Temp
var is_falling = false
export var permanent_death = true #If false, it will be respawned after some time.
var initial_global_position : Vector2
var is_respawning = false

func _ready():
	initial_global_position = get_global_position()

func _process(delta):
	_check_for_player_in_area()
	
	if is_on_floor():
		hitted_ground()

func _check_for_player_in_area():
	if is_falling:
		return
	
	for i in detect_area.get_overlapping_areas():
		var kb = i.get_owner()
		
		if kb is KinematicBody2D:
			if kb.is_on_floor():
				activate_fall()

func queue_free_start(idk):
	if permanent_death:
		queue_free()

func activate_fall():
	is_falling = true
	sprite_ani.play("Shaking")
	fall_delay_timer.start()
	FJ_AudioManager.sfx_env_platform_scramble.play()

func hitted_ground():
	if is_respawning:
		return
	
	if permanent_death:
		die()
	else:
		respawn_start()
	FJ_AudioManager.sfx_env_platform_explode.play()

func respawn_start():
	var death_effect = explosion_effect.instance()
	get_parent().add_child(death_effect)
	death_effect.global_position = global_position
	can_damage = false
	pf_bhv.INITIAL_STATE = false
	sprite_main.visible = false
	platform_collision_shape.disabled = true
	is_respawning = true
	respawn_timer.start()

func _on_FallDelayTimer_timeout():
	pf_bhv.INITIAL_STATE = true
	sprite_ani.play("Falling")
	FJ_AudioManager.sfx_env_platform_fall.play()

func _on_RespawnTimer_timeout():
	sprite_ani.play("Respawning")
	respawn_ready_timer.start()
	move_and_slide(Vector2(), Vector2(0, -1))
	set_global_position(initial_global_position)

func _on_RespawnReadyTimer_timeout():
	sprite_main.visible = true
	platform_collision_shape.disabled = false
	can_damage = true
	sprite_ani.stop()
	is_respawning = false
	is_falling = false