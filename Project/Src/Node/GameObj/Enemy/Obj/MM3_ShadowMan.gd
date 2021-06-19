extends BossCore

enum Phase1State {
	IDLE,
	JUMPING,
	HIDING,
	RESTARTING
}
enum Phase2State {
	STANDING,
	ABOUT_TO_JUMP,
	JUMPING
}
enum Phase3State {
	INITIAL,
	ENDING_ATTACK,
	FLEEING
}

const SHADOW_BLADE = preload("res://Src/Node/GameObj/Enemy/Obj/MM3_ShadowBlade.tscn")
const HOOHOO_BOMB = preload("res://Src/Node/GameObj/Enemy/Obj/MM9_c_HooHooBomb.tscn")
const EXPLOSION_EFF = preload("res://Src/Node/GameObj/Effects/LargeExplosion/LargeExplosion.tscn")
const LIFE_EN_LARGE = preload("res://Src/Node/GameObj/Pickups/LifeEnergyLarge.tscn")

onready var anim = $SpriteMain/Sprite/AnimationPlayer
onready var platform_bhv = $PlatformBehavior

var curr_phase = 1
var phase_1_state = Phase1State.IDLE
var phase_2_state = Phase2State.JUMPING
var phase_3_state = Phase3State.INITIAL
var pose_done : bool

func _ready() -> void:
	GameHUD.boss_vital_bar_palette.primary_sprite.modulate = NESColorPalette.WHITE4
	GameHUD.boss_vital_bar_palette.second_sprite.modulate = NESColorPalette.TORQUOISE2
	GameHUD.boss_vital_bar_palette.outline_sprite.modulate = NESColorPalette.BLACK1
	
	hide()
	anim.play("PoseAppear")
	yield(anim, "animation_finished")
	start_show_boss_health_bar()
	anim.play("Pose")
	yield(anim, "animation_finished")
	start_fill_up_health_bar()
	yield(self, "boss_done_posing")
	phase_1_state = Phase1State.HIDING
	pose_done = true


func _process(delta: float) -> void:
	_update_palette()

func _physics_process(delta: float) -> void:
	if not pose_done:
		return
	
	if curr_phase == 1:
		phase_1_process()
	if curr_phase == 2:
		phase_2_process()
	if curr_phase == 3:
		phase_3_process()
	
	_flee_if_player_dies()

func phase_1_process():
	if phase_1_state == Phase1State.IDLE:
		phase_1_state = Phase1State.JUMPING
		anim.play("Jump")
		platform_bhv.velocity.y = -320
		platform_bhv.WALK_SPEED = 60
		$FireBladesDelayTimer.start()
		return
	if phase_1_state == Phase1State.JUMPING:
		if get_sprite_main_direction() == 1:
			platform_bhv.simulate_walk_left = true
			platform_bhv.simulate_walk_right = false
		else:
			platform_bhv.simulate_walk_left = false
			platform_bhv.simulate_walk_right = true
		if platform_bhv.on_floor:
			if randi() % 7 == 0:
				phase_1_state = Phase1State.HIDING
			else:
				phase_1_state = Phase1State.RESTARTING
				anim.play("Idle")
				$Phase1RestartTimer.start()
	if phase_1_state == Phase1State.HIDING:
		anim.play("Hiding")
		$Phase1HideTimer.start()
		invis_timer.stop()
		flicker_anim.stop()
		sprite_main.show()
		$DamageSprite.hide()
		can_damage = false
		can_hit = false
		damage_sprite_ani.stop()
		eat_player_projectile = false
		phase_1_state = Phase1State.RESTARTING
	if phase_1_state == Phase1State.RESTARTING:
		platform_bhv.simulate_walk_left = false
		platform_bhv.simulate_walk_right = false

func phase_2_process():
	if phase_2_state == Phase2State.STANDING:
		anim.play("Idle")
		platform_bhv.WALK_SPEED = 0
		
		
	elif phase_2_state == Phase2State.ABOUT_TO_JUMP:
		phase_2_state = Phase2State.JUMPING
	elif phase_2_state == Phase2State.JUMPING:
		if current_hp < 13:
			platform_bhv.WALK_SPEED = 120
		else:
			platform_bhv.WALK_SPEED = 40
		
		if platform_bhv.on_floor:
			phase_2_state = Phase2State.STANDING

			$Phase2StandTimer.start()
	
	if get_sprite_main_direction() == 1:
		platform_bhv.simulate_walk_left = true
		platform_bhv.simulate_walk_right = false
	else:
		platform_bhv.simulate_walk_left = false
		platform_bhv.simulate_walk_right = true

func phase_3_process():
	if phase_3_state == Phase3State.INITIAL:
		invis_timer.stop()
		flicker_anim.stop()
		sprite_main.show()
		$DamageSprite.hide()
		can_damage = false
		can_hit = false
		damage_sprite_ani.stop()
		platform_bhv.WALK_SPEED = 0
		eat_player_projectile = false
		platform_bhv.velocity.y = 0
		$DashTimer.stop()
		$FireBladeDirectDelayTimer.stop()
		destroy_all_enemies()
		phase_3_state = Phase3State.ENDING_ATTACK
	if phase_3_state == Phase3State.ENDING_ATTACK:
		if not platform_bhv.on_floor:
			anim.play("Jump")
		else:
			flee()
			phase_3_state = Phase3State.FLEEING

func fire_blades():
	if curr_phase != 1:
		return
	
	var directions = [180, 115] if sprite_main.scale.x == 1 else [0, 65] # 2nd index is for shooting downward
	
	anim.play("JumpAttack")
	Audio.play_sfx("shadowblade")
	
	# Forward
	var blt = SHADOW_BLADE.instance()
	blt.contact_damage = 5
	get_parent().add_child(blt)
	blt.global_position = self.global_position
	blt.bullet_behavior.angle_in_degrees = directions[0]
	blt.bullet_behavior.gravity = 300
	
	# Downward
	if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
		var blt2 = SHADOW_BLADE.instance()
		get_parent().add_child(blt2)
		blt2.global_position = self.global_position
		blt2.bullet_behavior.angle_in_degrees = directions[1]
		blt2.bullet_behavior.allow_negative_speed = true
		blt2.bullet_behavior.acceleration = -550
	
	fling_hoohoo_bomb(-600, false)


func blink():
	var lim_x_min : Node2D
	var lim_x_max : Node2D
	
	var lim_x_min_nodes = get_tree().get_nodes_in_group("BlinkXMin")
	var lim_x_max_nodes = get_tree().get_nodes_in_group("BlinkXMax")
	
	if lim_x_min_nodes.empty():
		return
	if lim_x_max_nodes.empty():
		return
	
	lim_x_min = lim_x_min_nodes.back()
	lim_x_max = lim_x_max_nodes.back()
	
	global_position.x = rand_range(lim_x_min.global_position.x, lim_x_max.global_position.x)
	turn_toward_player()


func fling_hoohoo_bomb(velocity_y : float, _hittable := true):
	# Flings hoohoo bomb upward
	var bomb = HOOHOO_BOMB.instance()
	bomb.contact_damage = 5
	get_parent().add_child(bomb)
	bomb.global_position = self.global_position
	bomb.pf_bhv.velocity.y = velocity_y
	bomb.pf_bhv.INITIAL_STATE = true
	bomb.pickups_drop_enabled = false
	bomb.explode_countdown()
	bomb.DESTROY_OUTSIDE_SCREEN = false
	bomb.can_hit = _hittable


func fire_blades_direct():
	anim.play("JumpAttack")
	Audio.play_sfx("shadowblade")
	
	# Flings blade toward player
	var ag_adds = [0]
	
	if current_hp < 13:
		if Difficulty.difficulty == Difficulty.DIFF_NORMAL:
			ag_adds.append(50)
			ag_adds.append(-50)
		if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
			ag_adds.append(40)
			ag_adds.append(-40)
	if current_hp < 8:
		ag_adds.append(80)
		ag_adds.append(-80)
	
	for a in ag_adds:
		var ag_tw_player = self.global_position.angle_to_point(player.global_position)
		var blt = SHADOW_BLADE.instance()
		blt.contact_damage = 5
		get_parent().add_child(blt)
		blt.global_position = self.global_position
		blt.explode_on_hit = true
		if player != null:
			ag_tw_player = self.global_position.angle_to_point(player.global_position)
			blt.bullet_behavior.angle_in_degrees = rad2deg(ag_tw_player) - 180
		else:
			blt.bullet_behavior.angle_in_degrees = -get_sprite_main_direction() * 180
		blt.bullet_behavior.angle_in_degrees += a
		
		if Difficulty.difficulty == Difficulty.DIFF_NEWCOMER:
			blt.bullet_behavior.speed = 240
		if Difficulty.difficulty == Difficulty.DIFF_CASUAL:
			blt.bullet_behavior.speed = 300
		if Difficulty.difficulty == Difficulty.DIFF_NORMAL:
			blt.bullet_behavior.speed = 360
		if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
			blt.bullet_behavior.speed = 420
	
	fling_hoohoo_bomb(-200)
	
	# Make invisible as it breaks the invisibility to attack
	sprite_main.modulate = Color.white
	can_hit = true
	can_damage = true
	eat_player_projectile = true


func _flee_if_player_dies():
	if player == null:
		return
	
	if curr_phase == 1 and player.current_hp <= 0:
		curr_phase = 3


func flee():
	anim.play("Throwing")
	yield(anim, "animation_finished")
	anim.play("Throw")
	
	for times in 9:
		for count in 3:
			var eff = EXPLOSION_EFF.instance()
			get_parent().add_child(eff)
			eff.global_position = self.global_position + Vector2(rand_range(-32, 32), rand_range(-32, 32))
		
		Audio.play_sfx("buster_minishot")
		
		if times == 7:
			anim.play("Flee")
		
		yield(get_tree().create_timer(0.12), "timeout")
	
	if player != null and player.current_hp <= 0:
		return
	
	# Drops Life pickups
	if Difficulty.difficulty < Difficulty.DIFF_NORMAL:
		var life_en = LIFE_EN_LARGE.instance()
		get_parent().add_child(life_en)
		life_en.global_position = global_position
	
	yield(anim, "animation_finished")
	GameHUD.boss_vital_bar_palette.second_sprite.modulate = NESColorPalette.CYAN2
	current_hp += 19
	GameHUD.fill_boss_vital_bar(19)
	yield(get_tree().create_timer(1.0), "timeout")
	anim.play("FleeReturn")
	turn_toward_player()
	yield(anim, "animation_finished")
	curr_phase = 2
	is_invincible = false
	$Phase2StandTimer.start()


func _on_FireBladeDirectDelayTimer_timeout() -> void:
	fire_blades_direct()

func _on_PlatformBehavior_by_wall() -> void:
	sprite_main.scale.x = -sprite_main.scale.x

func _on_FireBladesDelayTimer_timeout() -> void:
	fire_blades()

func _on_Phase1RestartTimer_timeout() -> void:
	phase_1_state = Phase1State.IDLE

func _on_Phase1HideTimer_timeout() -> void:
	phase_1_state = Phase1State.IDLE
	
	can_damage = true
	can_hit = true
	is_invincible = false
	eat_player_projectile = true

func _on_MM3_ShadowMan_taken_damage(value, target, player_proj_source) -> void:
	if current_hp <= 1 and curr_phase == 1 and Difficulty.difficulty > Difficulty.DIFF_NEWCOMER:
		current_hp = 1
		GameHUD.update_boss_vital_bar(current_hp)
		curr_phase = 3

func _update_palette():
	$SpriteMain/Sprite/Palette.frame = sprite.frame
	$SpriteMain/Sprite/Palette.modulate = GameHUD.boss_vital_bar_palette.second_sprite.modulate


func _on_MM3_ShadowMan_dying() -> void:
	Audio.stop_sfx("shadowblade")
	Audio.stop_sfx("thunder")
	Audio.stop_sfx("explosion")


func _on_MM3_ShadowMan_taking_damage(value, target, player_proj_source) -> void:
	if player_proj_source.projectile_name == "ring":
		if curr_phase == 1:
			if Difficulty.difficulty == Difficulty.DIFF_NEWCOMER:
				event_damage = 3
			else:
				event_damage = 2
			
			player_proj_source.invis_time_apply = 0.2
		if curr_phase == 2:
			if Difficulty.difficulty <= Difficulty.DIFF_NORMAL:
				event_damage = 4
			if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
				event_damage = 3
			
			player_proj_source.invis_time_apply = 1.1


func _on_Phase2StandTimer_timeout() -> void:
	can_hit = false
	invis_timer.stop()
	flicker_anim.stop()
	sprite_main.show()
	$DamageSprite.hide()
	can_damage = false
	can_hit = false
	damage_sprite_ani.stop()
	eat_player_projectile = false
	hide()
	
	if current_hp < 13:
		if Difficulty.difficulty < Difficulty.DIFF_NORMAL:
			$Phase2HideTimer.wait_time = rand_range(0.7, 1.3)
		if Difficulty.difficulty >= Difficulty.DIFF_NORMAL:
			$Phase2HideTimer.wait_time = rand_range(0.1, 0.3)
	else:
		if Difficulty.difficulty < Difficulty.DIFF_NORMAL:
			$Phase2HideTimer.wait_time = rand_range(1.3, 2)
		if Difficulty.difficulty >= Difficulty.DIFF_NORMAL:
			$Phase2HideTimer.wait_time = rand_range(0.4, 0.9)
	
	$Phase2HideTimer.start()


func _on_Phase2HideTimer_timeout() -> void:
	if player != null and player.current_hp <= 0:
		return
	
	phase_2_state = Phase2State.ABOUT_TO_JUMP
	
	if Difficulty.difficulty < Difficulty.DIFF_NORMAL:
		platform_bhv.velocity.y = -600
	if Difficulty.difficulty == Difficulty.DIFF_NORMAL:
		platform_bhv.velocity.y = -550
	if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
		platform_bhv.velocity.y = -500
	anim.play("Jump")
	$FireBladeDirectDelayTimer.start()
	turn_toward_player()
	sprite_main.modulate = Color.black
	is_invincible = false
	eat_player_projectile = false
	blink()
	show()
	
