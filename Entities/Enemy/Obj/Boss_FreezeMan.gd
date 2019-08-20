extends BossCore

onready var pf_bhv = $PlatformBehavior
onready var freeze_man_ani = $FreezeManAni
onready var flip = $Flip
onready var flood_floor_shoot_pos = $Flip/FloodFloorShootPos
onready var freeze_cracker_shoot_pos = $Flip/FreezeCrackerShootPos
onready var launch_icicle_pos = $Flip/LaunchIciclePos

enum ATTACK_PATTERN {
	IDLE,
	MOVE_TO_EDGE,
	FIRE_FREEZE_CRACKER,
	FLOOD_FLOOR_W_ICE,
	LAUNCH_ICICLE_BALL
}

onready var PHASE_2_AT_HP = hit_points_base / 3
var is_provoked = false
var current_atk_pattern : int = 0
var dir = 0

#Patterns temp
var is_freeze_cracker_fired := false
var fire_freeze_cracker_jumped = false
var is_preparing_freeze_cracker = false
var flood_floor_w_ice_move_count_left = 10
var flood_floor_w_ice_is_jumped = false
var flood_floor_w_ice_launched = false

#prelaod
var ice_shard_effect = preload("res://Entities/Effects/IceCrackEffect/IceShardEffect.tscn")
var freeze_cracker_proj = preload("res://Entities/Enemy/Obj/FreezeCracker.tscn")

#Spawn ice effect
func spawn_ice_shard_on_self():
	var directions = [-10, -45, -90, -135, -170]
	for i in directions:
		var effect = ice_shard_effect.instance()
		get_parent().add_child(effect)
		effect.position = self.position
		effect.bullet_bhv.angle_in_degrees = i
	
	FJ_AudioManager.sfx_combat_ice_break.play()

func _process(delta: float) -> void:
	if is_posing:
		return
	
	if current_atk_pattern == ATTACK_PATTERN.IDLE:
		if (
			Input.is_action_pressed("game_left") or
			Input.is_action_pressed("game_right") or
			Input.is_action_pressed("game_jump") or
			Input.is_action_just_pressed("game_action") or
			Input.is_action_just_released("game_action")
		):
			current_atk_pattern = ATTACK_PATTERN.MOVE_TO_EDGE
			turn_toward_player()
	elif current_atk_pattern == ATTACK_PATTERN.MOVE_TO_EDGE:
		#Move to the edge by current direction. If the player shoots,
		#freeze man will jump.
		move_by_current_direction()
		
		if pf_bhv.on_floor:
			freeze_man_ani.play("Walking")
		else:
			freeze_man_ani.play("Jumping")
		
		pf_bhv.simulate_jump = Input.is_action_just_pressed("game_action") or Input.is_action_just_released("game_action")
		
		#Stop jumping if by wall.
		if pf_bhv.on_wall:
			pf_bhv.simulate_jump = false #Turn off for preventing walk+jump glitch
		
		#Changes pattern if on floor and is at edge of screen.
		if pf_bhv.on_wall and pf_bhv.on_floor:
			current_atk_pattern = ATTACK_PATTERN.FIRE_FREEZE_CRACKER
			turn()
			is_freeze_cracker_fired = false
			fire_freeze_cracker_jumped = false
			is_preparing_freeze_cracker = false
	elif current_atk_pattern == ATTACK_PATTERN.FIRE_FREEZE_CRACKER:
		stop_moving()
		
		if not is_freeze_cracker_fired:
			freeze_man_ani.play("JumpHigh")
		
		#Prepare to shoot freeze cracker while in the air
		if fire_freeze_cracker_jumped && pf_bhv.velocity.y > 20 and !pf_bhv.on_floor:
			freeze_man_ani.play("PrepareFreezeCracker")
			is_preparing_freeze_cracker = true
			pf_bhv.simulate_jump = false
		
		if is_preparing_freeze_cracker and pf_bhv.on_floor:
			freeze_man_ani.play("ShootFreezeCracker")
			is_freeze_cracker_fired = true
			flood_floor_w_ice_is_jumped = false
			flood_floor_w_ice_launched = false
	elif current_atk_pattern == ATTACK_PATTERN.FLOOD_FLOOR_W_ICE:
		move_by_current_direction()
		
		if flood_floor_w_ice_move_count_left > 0:
			freeze_man_ani.play("Walking")
			flood_floor_w_ice_move_count_left -= 60 * delta
			return
		
		
		
		pf_bhv.WALK_SPEED = 30
		pf_bhv.JUMP_SPEED = 450
		
		if not flood_floor_w_ice_is_jumped:
			flood_floor_w_ice_is_jumped = true
			freeze_man_ani.play("Jumping")
			pf_bhv.simulate_jump = true
		else:
			if pf_bhv.velocity.y > -20 && !flood_floor_w_ice_launched:
				flood_floor_w_ice_launched = true
				freeze_man_ani.play("FloodFloor")
				pf_bhv.simulate_jump = false
		
		if flood_floor_w_ice_is_jumped && flood_floor_w_ice_launched && pf_bhv.on_floor:
			current_atk_pattern = ATTACK_PATTERN.LAUNCH_ICICLE_BALL
			flood_floor_w_ice_move_count_left = randi() % 60 + 10
			
		
	elif current_atk_pattern == ATTACK_PATTERN.LAUNCH_ICICLE_BALL:
		stop_moving()
		
		pf_bhv.WALK_SPEED = 120
		pf_bhv.JUMP_SPEED = 300
		if current_hp < PHASE_2_AT_HP:
			freeze_man_ani.play("ThrowIcicle v2")
		else:
			freeze_man_ani.play("ThrowIcicle")
		
	

func _on_Freeze_Man_boss_done_posing() -> void:
	pf_bhv.INITIAL_STATE = true
	freeze_man_ani.play("Idle")

func turn_toward_player():
	if player != null:
		if player.global_position.x < self.global_position.x:
			flip.scale.x = 1
		else:
			flip.scale.x = -1

func turn():
	flip.scale.x = -flip.scale.x

func jump_high():
	pf_bhv.simulate_jump = true
	fire_freeze_cracker_jumped = true

func _on_FreezeManAni_animation_finished(anim_name: String) -> void:
	if anim_name == "ShootFreezeCracker":
		current_atk_pattern = ATTACK_PATTERN.FLOOD_FLOOR_W_ICE
	
	if anim_name == "ThrowIcicle" or anim_name == "ThrowIcicle v2":
		is_provoked = false
		
		freeze_man_ani.play("Idle")
		turn_toward_player()
		current_atk_pattern = ATTACK_PATTERN.IDLE

func move_by_current_direction():
	if flip.scale.x == 1:
		pf_bhv.simulate_walk_left = true
		pf_bhv.simulate_walk_right = false
	if flip.scale.x == -1:
		pf_bhv.simulate_walk_left = false
		pf_bhv.simulate_walk_right = true

func stop_moving():
	pf_bhv.simulate_walk_left = false
	pf_bhv.simulate_walk_right = false

func fire_freeze_cracker():
	var proj = freeze_cracker_proj.instance()
	get_parent().add_child(proj)
	proj.global_position = freeze_cracker_shoot_pos.global_position
	if flip.scale.x == 1:
		proj.bullet_behavior.angle_in_degrees = 180
	
	if current_hp < PHASE_2_AT_HP:
		var directions_left = [195, 210, 225, 240]
		var directions_right = [-15, -30, -45, -60]
		for i in directions_left.size():
			proj = freeze_cracker_proj.instance()
			get_parent().add_child(proj)
			proj.global_position = freeze_cracker_shoot_pos.global_position
			if flip.scale.x == 1:
				proj.bullet_behavior.angle_in_degrees = directions_left[i]
			else:
				proj.bullet_behavior.angle_in_degrees = directions_right[i]

func fire_flood_icy_floor():
	var proj_count = 3 if current_hp < PHASE_2_AT_HP else 1
	var angles = [0, 60, -60]
	
	for i in proj_count:
		var proj = freeze_cracker_proj.instance()
		get_parent().add_child(proj)
		proj.global_position = flood_floor_shoot_pos.global_position
		if player != null:
			var ag = self.global_position.angle_to_point(player.global_position)
			proj.bullet_behavior.angle_in_degrees = rad2deg(ag) - 180 + angles[i]
		else:
			proj.bullet_behavior.angle_in_degrees = 180 + angles[i]
		proj.behavior_type = 1

func fire_icicle(new_acceleration = 120):
	var proj = freeze_cracker_proj.instance()
	get_parent().add_child(proj)
	proj.global_position = launch_icicle_pos.global_position
	proj.bullet_behavior.angle_in_degrees = -90
	proj.bullet_behavior.acceleration = new_acceleration
	proj.bullet_behavior.speed = 200
	proj.behavior_type = 2
