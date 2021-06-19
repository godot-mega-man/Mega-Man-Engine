extends EnemyCore


const STUN_PLAYER_DEBUFF = preload("res://Src/Node/GameObj/Enemy/Obj/StunPlayerDebuff.tscn")


export (float) var attack_range = 8
export (float) var float_up_speed = 150


onready var sprite_ani = $SpriteMain/Sprite/Ani
onready var pf_bhv = $PlatformBehavior


var is_hover_attacking = false


func _ready() -> void:
	if Difficulty.difficulty == Difficulty.DIFF_NEWCOMER:
		current_hp = 10
		sprite_ani.playback_speed = 0.9
	if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
		current_hp = 25
		sprite_ani.playback_speed = 1.2


func _process(delta: float) -> void:
	#Stomps when nearby player.
	if is_hover_attacking:
		pf_bhv.velocity.y = -float_up_speed
		
		pf_bhv.simulate_walk_left = sprite_main.scale.x == 1
		pf_bhv.simulate_walk_right = !sprite_main.scale.x == 1
		
		if global_position.x > player.global_position.x - 8 and global_position.x < player.global_position.x + 8:
			initiate_stomping_process()
	else:
		pf_bhv.simulate_walk_left = false
		pf_bhv.simulate_walk_right = false


func initiate_stomping_process():
	is_hover_attacking = false
	sprite_ani.play("Stomping")
	pf_bhv.velocity = Vector2()


func hover_forward():
	Audio.play_sfx("powerlaunch")
	sprite_ani.play("Hovering")
	is_hover_attacking = true


#Sets fallspeed to max
func stomp():
	Audio.play_sfx("powerfall")
	set_fall_speed_to_max()


func set_fall_speed_to_max():
	pf_bhv.velocity.y = pf_bhv.MAX_FALL_SPEED


func finish_landing():
	sprite_ani.play("Launch")


func _on_PlatformBehavior_landed() -> void:
	sprite_ani.play("Landing")
	
	#Stops falling sound
	Audio.play_sfx("powerlanding")
	
	# On normal difficulty,
	# Causes a stun to all players standing on the ground
	if Difficulty.difficulty > Difficulty.DIFF_CASUAL:
		level_camera.camera_shaker.shake(1.3, 50, 4)
		
		for p in get_tree().get_nodes_in_group("Player"):
			if not p.is_on_floor():
				continue
			
			var stun = STUN_PLAYER_DEBUFF.instance()
			p.add_child(stun)


func _on_PlatformBehavior_hit_ceiling() -> void:
	initiate_stomping_process()
