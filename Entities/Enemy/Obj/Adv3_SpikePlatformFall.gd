extends EnemyCore

onready var pf_bhv = $PlatformBehavior
onready var detect_area = $DetectArea2D
onready var fall_delay_timer = $FallDelayTimer
onready var sprite_ani = $SpriteMain/Ani

#Temp
var is_falling = false

func _process(delta):
	_check_for_player_in_area()
	
	if is_on_floor():
		die()

func _check_for_player_in_area():
	if is_falling:
		return
	
	for i in detect_area.get_overlapping_areas():
		var kb = i.get_owner()
		
		
		if kb is KinematicBody2D:
			if kb.is_on_floor():
				activate_fall()

func activate_fall():
	is_falling = true
	sprite_ani.play("Shaking")
	fall_delay_timer.start()

func _on_FallDelayTimer_timeout():
	pf_bhv.INITIAL_STATE = true
	sprite_ani.play("Falling")
