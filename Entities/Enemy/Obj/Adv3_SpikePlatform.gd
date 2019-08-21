extends EnemyCore

onready var pf_bhv = $PlatformBehavior
onready var detect_player_area = $DetectPlayerArea2D
onready var fall_delay_timer = $FallDelayTimer
onready var sprite_ani = $SpriteMain/Ani

#Temp
var is_falling = false

func _process(delta):
	_check_for_player_in_area()

func _check_for_player_in_area():
	if is_falling:
		return
	
	for i in detect_player_area.get_overlapping_areas():
		var player = i.get_owner()
		if player is Player:
			
			if player.pf_bhv.on_floor:
				activate_fall()

func activate_fall():
	is_falling = true
	sprite_ani.play("Shaking")
	fall_delay_timer.start()

func _on_PlatformBehavior_landed():
	die()

func _on_FallDelayTimer_timeout():
	pf_bhv.INITIAL_STATE = true
	sprite_ani.play("Falling")
