extends KinematicBody2D
class_name Player

signal player_die
signal launched_attack
signal player_die_normally

#Starting location:
#  -Auto: Uses current location as a starting point. If a player
#         teleported from warp zones, this option will be overriden.
#  -Ignore Teleporters: Always uses current location as a starting point 
#                       of the map. Player transitioned here by warp zones
#                       will be ignored.
#  -Never (Unsafe): Default starting location will be ignored.
#                   Warp zones may overrides this option.
export(int, "Auto", "Ignore Teleporters", "Never (Unsafe)") var STARTING_LOCATION = 0

export (NodePath) var level_path
export (NodePath) var tilemap_path
export (Resource) var player_character_data_res
export (int) var CURRENT_PALETTE_STATE #Don't touch this!

#Player's stats
const HP_BASE : int = 28
const MP_BASE : int = 20
const DAMAGE_BASE = 2
const DEFAULT_INVIS_TIME : float = 1.4
const ATTACK_HOTKEY = 'game_action'
const ATTACK_HOTKEY_1 = 'game_hotkey1'
const PROJECTILE_ON_SCREEN_LIMIT : float = 3.0
const CHARGE_MEGABUSTER_STARTING_TIME = 0.6
const FULLY_CHARGE_MEGABUSTER_STARTING_TIME = 1.6
const TAKING_DAMAGE_SLIDE_LEFT := -20
const TAKING_DAMAGE_SLIDE_RIGHT := 20
const SLIDE_FRAME : float = 26.0
const SLIDE_SPEED : float = 150.0
const SUICIDE_KEY = KEY_2

#Current stats.
var current_hp = HP_BASE
var current_mp = MP_BASE
var max_hp = 28
var max_mp = 20
var attack_power = DAMAGE_BASE
var is_invincible = false
var is_attack_ready = true
var is_fell_into_pit = false
var attack_cooldown_apply_time = 0.05
var attack_type = 0 #0:By Pressing action button, 1:Holding action button
var attack_hold_time = 0 #Increase as the attack button is pressed.
var mega_buster_charge_lv = 0
var is_cutscene_mode = false #When true, player won't take damage while in cutscene
var is_cancel_holding_jump_allowed = true
var is_taking_damage = false
var taking_damage_slide_pos := 0 #Use only x-axis!
var is_sliding = false
var slide_remaining : float
var slide_direction_x : float = 0 #-1 and 1 value are used.


#Player's child nodes
onready var pf_bhv := $PlatformBehavior as FJ_PlatformBehavior2D
onready var area = $Area2D
onready var area_collision := $Area2D/CollisionShape2D as CollisionShape2D
onready var area_slide_collision := $Area2D/SlideCollisionShape2D as CollisionShape2D
onready var collision_shape := $CollisionShape2D as CollisionShape2D
onready var slide_collision_shape := $SlideCollisionShape2D
onready var platformer_sprite = $PlatformerSprite
onready var animation_player = $AnimationPlayer
onready var shoot_pos = $PlatformerSprite/ShootPos
onready var attack_cooldown_timer = $AttackCooldownTimer
onready var invis_timer = $InvincibleTimer
onready var taking_damage_timer = $TakingDamageTimer
onready var transition_tween := $TransitionTween as Tween
onready var damage_sprite = $DamageSprite
onready var damage_sprite_ani = $DamageSprite/Ani
onready var slide_dust_pos = $PlatformerSprite/SlideDustPos
onready var palette_ani_player = $PlatformerSprite/PaletteAniPlayer
onready var palette_ani_player_changer = $PlatformerSprite/PaletteAniPlayer/PaletteAniChanger
onready var death_freeze_timer = $DeathFreezeTimer

onready var level_camera := get_node_or_null("/root/Level/Camera2D") as Camera2D

onready var global_var = get_node("/root/GlobalVariables")
onready var tile_map = get_node("/root/Level/TileMap")
onready var currency_manager = get_node("/root/CurrencyManager")
onready var player_stats = get_node("/root/PlayerStats")

#Preloading objects... Ex: Bullets.
var proj_megabuster = preload("res://Entities/PlayerProjectile/PlayerProjectile_MegaBuster.tscn")
var proj_chargedmegabuster1 = preload("res://Entities/PlayerProjectile/PlayerProjectile_ChargedMegaBuster1.tscn")
var proj_chargedmegabuster2 = preload("res://Entities/PlayerProjectile/PlayerProjectile_ChargedMegaBuster2.tscn")
var dmg_counter = preload("res://GUI/DamageCounter.tscn")
var explosion_effect = preload("res://Entities/Effects/Explosion/Explosion.tscn")
var coin_particles = preload("res://Entities/Effects/Particles/CoinParticles.tscn")
var vulnerable_effect = preload("res://Entities/Effects/VulnerableEffect/VulnerableEffect.tscn")
var slide_dust_effect = preload("res://Entities/Effects/SlideDust/SlideDust.tscn")
'''---------------------------------------------------------------------------------'''

func _ready():
	#Set starting location. (By default, or from teleporters, warp zones, etc.)
	set_starting_location()
	set_starting_stats() #Hp, for ex.
	
	#Connect attack_cooldown_timer's signal
	area.connect('area_entered', self, '_on_area_entered')
	attack_cooldown_timer.connect("timeout", self, '_on_attack_cooldown_timer_timeout')
	invis_timer.connect('timeout', self, '_on_invis_timer_timeout')
	self.connect('tree_exiting', self, '_on_tree_exiting')
	player_stats.connect("leveled_up", self, "_on_leveled_up")
	
	#Let's the entire scene know that the player is alive.
	player_stats.is_died = false
	
	update_player_sprite_texture()
	_update_current_character_palette_state(true)

func _process(delta):
	set_vflip_by_keypress()
	press_attack_check(delta)
	check_for_area_collisions()
	check_sliding(delta)
	check_press_jump_or_sliding()
	check_holding_jump_key()
	check_taking_damage()
	update_platformer_sprite_color_palettes()

func _input(event):
	if event is InputEventKey:
		if event.get_scancode() == SUICIDE_KEY and event.is_pressed():
			if !pf_bhv.INITIAL_STATE:
				return
			if !pf_bhv.CONTROL_ENABLE:
				return
			if current_hp <= 0:
				return
			player_death()
			GameHUD.update_player_vital_bar(0)

#Check if jump key is holding while in the air.
#Otherwise, resets velocity y
func check_holding_jump_key():
	if is_cancel_holding_jump_allowed:
		if !Input.is_action_pressed("game_jump") and pf_bhv.velocity.y < 0 and pf_bhv.on_air_time > 0:
			pf_bhv.velocity.y = 0
			is_cancel_holding_jump_allowed = false

func set_starting_location():
	#First, get data from checkpoint manager.
	var is_default_location = CheckpointManager.saved_player_position == Vector2(0, 0)
	#Update checkpoint's position if not set.
	if !CheckpointManager.has_checkpoint():
		CheckpointManager.update_checkpoint_position(global_position, get_tree().get_current_scene().get_filename(), global_var.current_view)
		print(self.name, ': No checkpoint available. Automatically updated.')
	
	if STARTING_LOCATION == 0: #Auto
		if !is_default_location:
			global_position = CheckpointManager.saved_player_position
	if STARTING_LOCATION == 2: #Never (Unsafe)
		global_position = CheckpointManager.saved_player_position
		if is_default_location:
			push_warning(str(self) + str(name) + ': Default starting location for a player is not configured!')
	
	#If player died last time, checkpoint will be used
	#and set current player's position.
	if player_stats.is_died:
		global_position = CheckpointManager.current_checkpoint_position

func set_starting_stats():
	#When player enters scene for the first time (Enter level, died last time),
	#the player's health will be restored.
	#Otherwise, set current hp to previous health from last scene.
	if player_stats.restore_hp_on_load:
		player_stats.restore_hp_on_load = false
	else:
		current_hp = player_stats.current_hp
	GameHUD.update_player_vital_bar(current_hp)

func _on_PlatformerBehavior_fell_into_pit() -> void:
	current_hp = 0
	is_fell_into_pit = true
	
	#Update GUI
	GameHUD.update_player_vital_bar(current_hp)
	player_death()

func set_vflip_by_keypress():
	if pf_bhv.walk_left:
		platformer_sprite.scale.x = -1
	if pf_bhv.walk_right:
		platformer_sprite.scale.x = 1

func press_attack_check(delta : float):
	if !pf_bhv.CONTROL_ENABLE or !pf_bhv.INITIAL_STATE:
		return
	
	#Character will start to shoot/attack when the player pressed "action key"
	#To be able to attack, all of the following conditions must be met:
	#  -There is a keypress stroke.
	#  -Attack is not in cooldown and must be ready (Rapid firing is the exception).
	if is_attack_ready:
		if attack_type == 0:
			if Input.is_action_just_pressed(ATTACK_HOTKEY):
				if not can_spawn_projectile() or is_sliding:
					return
				start_launching_attack(proj_megabuster)
				FJ_AudioManager.sfx_combat_buster.play()
	
	#Check if releasing attack button or holding either way
	if not Input.is_action_pressed(ATTACK_HOTKEY):
		if not can_spawn_projectile() or is_sliding:
			return
		
		if attack_hold_time > FULLY_CHARGE_MEGABUSTER_STARTING_TIME:
			start_launching_attack(proj_chargedmegabuster2)
			FJ_AudioManager.sfx_combat_buster_fullycharged.play()
			FJ_AudioManager.sfx_combat_buster_charging.call_deferred("stop")
		elif attack_hold_time > CHARGE_MEGABUSTER_STARTING_TIME:
			start_launching_attack(proj_chargedmegabuster1)
			FJ_AudioManager.sfx_combat_buster_minicharged.play()
			FJ_AudioManager.sfx_combat_buster_charging.call_deferred("stop")
		
		attack_hold_time = 0
		mega_buster_charge_lv = 0
		palette_ani_player.play("Init")
		palette_ani_player_changer.stop()
	else:
		attack_hold_time += delta
		
		if attack_hold_time > CHARGE_MEGABUSTER_STARTING_TIME and not can_spawn_projectile():
			attack_hold_time = CHARGE_MEGABUSTER_STARTING_TIME
			return
		
		#Charge actions
		if mega_buster_charge_lv == 0:
			if attack_hold_time > CHARGE_MEGABUSTER_STARTING_TIME:
				mega_buster_charge_lv = 1
				FJ_AudioManager.sfx_combat_buster_charging.play()
				palette_ani_player_changer.play("Charging")
		elif mega_buster_charge_lv == 1:
			if attack_hold_time > FULLY_CHARGE_MEGABUSTER_STARTING_TIME:
				mega_buster_charge_lv = 2
				palette_ani_player_changer.play("FullyCharged")

func start_launching_attack(packed_scene : PackedScene) -> void:
	var bullet = packed_scene.instance()
	get_parent().add_child(bullet) #Deploy projectile from player.
	
	bullet.position = shoot_pos.global_position
	bullet.bullet_behavior.angle_in_degrees = -90 + (90.0 * platformer_sprite.scale.x)
	bullet.sprite.scale.x = platformer_sprite.scale.x
	
	#Calculate damage
	var total_damage = 0
	total_damage = DAMAGE_BASE + bullet.DAMAGE_POWER
	bullet.DAMAGE_POWER = total_damage #Final damage output
	
	#Emit signal
	emit_signal("launched_attack")

#Check if the projectile is not above limit
func can_spawn_projectile() -> bool:
	var size : float = 0
	
	for i in get_tree().get_nodes_in_group("PlayerProjectile"):
		if i is PlayerProjectile:
			size += i.projectile_limit_cost
	
	return size < PROJECTILE_ON_SCREEN_LIMIT

#OBSOLETED! Will be removed and rewritten to a better one.
func start_launching_attack_skill() -> void:
	return

func _on_attack_cooldown_timer_timeout():
	is_attack_ready = true #Ready to attack again

func check_for_area_collisions():
	var all_area = area.get_overlapping_areas()
	
	for i in all_area:
		if i.is_in_group("Coin"):
			#Get coin's information
			var coin = i.get_parent() as CoinCore
			
			#Check if coin/item is collectable
			if coin.is_ready_to_be_collected:
				if coin.is_coin():
					#Add coin PERMANENTLY to your bank!!
					currency_manager.game_coin += coin.COIN_VALUE
					#Update coin GUI too! Yeah! You've made a progress.
#					update_gui("update_coin")
				elif coin.is_diamond():
					#Add diamond PERMANENTLY to your bank!!
					currency_manager.game_diamond += coin.COIN_VALUE
					#Update coin GUI too! Yeah! You've made a progress.
#					update_gui("update_diamond")
				#Destroy coin
				coin.player_collected_coin()

#When ANY kind of 'area' collides with player (once),
#Do anything below here.
func _on_area_entered(body):
	pass #CURRENTLY DOING NOTHING

func player_take_damage(damage_amount : int, repel_player : bool = false, repel_position : Vector2 = Vector2(0, 0), repel_power : int = 300, apply_new_invis : bool = false, apply_new_invis_time : float = 0.1):
	if is_invincible or is_cutscene_mode:
		return
	
	#Subtracting health from damage taken.
	current_hp -= damage_amount
	#Repel player to the opposite direction the player is facing.
	if repel_player:
		repel_player()
	
	#Platformer Sprite plays damage animation.
	platformer_sprite.is_taking_damage = true
	
	#Disables movement and controls.
	pf_bhv.CONTROL_ENABLE = false
	taking_damage_timer.start()
	
	#Player become invincible after taking damage.
	#While invincible, player won't be able to take damage,
	#which is good! But that won't last long...
	var new_invis_time
	if apply_new_invis:
		#Some enemies wanted to touch you for 1 damage, for example.
		new_invis_time = apply_new_invis_time 
	else:
		new_invis_time = self.DEFAULT_INVIS_TIME #Default invis time.
	is_invincible = true
	invis_timer.start(new_invis_time)
	
	#Plays flashing animation
	if current_hp > 0:
		damage_sprite_ani.play("Flashing")
	
	#Spawn damage counter
	spawn_damage_counter(damage_amount)
	
	#Spawn vulnerable effect
	spawn_vulnerable_effect()
	
	#Stops sliding if possible (no ceiling collision)
	if not test_normal_check_collision():
		stop_sliding(true)
	
	#Check for death
	if current_hp <= 0:
		player_death()
		
	else:
		FJ_AudioManager.sfx_character_player_damage.play()
		animation_player.play("Invincible")
	
	GameHUD.update_player_vital_bar(current_hp)
	
	is_taking_damage = true

func check_taking_damage():
	if is_taking_damage and not is_sliding:
		pf_bhv.velocity.x = taking_damage_slide_pos

func check_press_jump_or_sliding():
	if !(pf_bhv.INITIAL_STATE and pf_bhv.CONTROL_ENABLE):
		return
	
	if not is_taking_damage:
		if Input.is_action_just_pressed("game_jump"):
			if pf_bhv.on_floor:
				if Input.is_action_pressed("game_down"):
					#To be able to slide, must be on floor and not sliding.
					#In addition, the player must not be nearby wall
					#by current direction the player is facing.
					if platformer_sprite.scale.x == 1:
						if not (is_sliding or test_slide_check_collision(Vector2(1, -1))):
							start_sliding()
					else:
						if not (is_sliding or test_slide_check_collision(Vector2(-1, -1))):
							start_sliding()
				else:
					#If the player tries to jump while sliding under ceiling,
					#it would fail.
					if !(is_sliding and test_normal_check_collision()):
						pf_bhv.jump_start()

func check_sliding(delta : float):
	if !(pf_bhv.INITIAL_STATE and pf_bhv.CONTROL_ENABLE):
		return
	
	check_canceling_slide()
	
	if is_sliding and (!pf_bhv.on_floor or pf_bhv.on_wall):
		if pf_bhv.on_wall:
			if not test_normal_check_collision():
				pf_bhv.left_right_key_press_time = 0
				stop_sliding() #Stop normally
		else:
			stop_sliding(true) #Force stop
	
	if is_sliding:
		slide_direction_x = platformer_sprite.scale.x
		pf_bhv.velocity.x = SLIDE_SPEED * slide_direction_x
		pf_bhv.left_right_key_press_time = 30 #Fix tipping toe glitch
	
	#Decrease slide remaining
	if slide_remaining > 0:
		slide_remaining -= 60 * delta
	elif slide_remaining < 0 and slide_remaining > -10:
		stop_sliding()

func check_canceling_slide():
	if is_sliding:
		if Input.is_action_just_pressed("game_left"):
			if slide_direction_x == 1: #Right
				pf_bhv.left_right_key_press_time = 0
				stop_sliding()
		if Input.is_action_just_pressed("game_right"):
			if slide_direction_x == -1:
				pf_bhv.left_right_key_press_time = 0
				stop_sliding()

func change_player_current_hp(var amount : int):
	current_hp += amount
	if current_hp < 0:
		current_hp = 0
		player_death()
	if current_hp > max_hp:
		current_hp = max_hp
	GameHUD.update_player_vital_bar(current_hp)

func heal_to_full_hp():
	current_hp = max_hp
	GameHUD.update_player_vital_bar(current_hp)

func heal(var amount : int):
	current_hp += abs(amount)
	if current_hp > max_hp:
		current_hp = max_hp
	GameHUD.fill_player_vital_bar(amount)

#When the invincible's timer runs out, player will be able to get hurt again.
func _on_invis_timer_timeout():
	is_invincible = false
	animation_player.stop()
	platformer_sprite.visible = true #Due to animation glitch, this will surely fix it.

func repel_player():
	pf_bhv.velocity = Vector2()
	if platformer_sprite.scale.x == -1:
		taking_damage_slide_pos = TAKING_DAMAGE_SLIDE_RIGHT
	else:
		taking_damage_slide_pos = TAKING_DAMAGE_SLIDE_LEFT

func spawn_damage_counter(damage, var spawn_offset : Vector2 = Vector2(0,0)):
	if !GameSettings.gameplay.damage_popup_player:
		return
	
	var dmg_text = dmg_counter.instance() #Instance DamageCounter
	get_parent().add_child(dmg_text) #Spawn
	dmg_text.label.text = str(damage) #Set child node's text
	dmg_text.global_position = self.global_position #Set position to player
	dmg_text.global_position += spawn_offset #Spawn offset
	dmg_text.get_node('Label').add_color_override("font_color", Color(1,0,0,1))

func spawn_vulnerable_effect():
	if current_hp <= 0:
		return
	
	var eff = vulnerable_effect.instance()
	get_parent().add_child(eff)
	eff.global_position = self.global_position

#When the player's health drops below zero, player won't be able to
#continue their journey.
#Why? The character can die... but that won't affect
#the main story. You may get a game over screen or lost 1UP.
func player_death():
	#Stop mega buster charging sound.
	FJ_AudioManager.sfx_combat_buster_charging.call_deferred("stop")
	#Stops landing sound
	FJ_AudioManager.sfx_character_land.call_deferred("stop")
	#Stops item sound #TODO: remove this if no longer used.
	FJ_AudioManager.sfx_collectibles_item.stop()
	
	#Stop music
	FJ_AudioManager.stop_bgm()
	
#	#Shake the camera (if exists)
#	if level_camera != null:
#		level_camera.shake_camera(0.5, 100, 30)
	
	#Restore hp on scene load. Because we wanted player to restore health
	#after the player is respawned.
	player_stats.restore_hp_on_load = true
	
	player_stats.is_died = true #PLAYER IS DEAD!
	
	if is_fell_into_pit:
		die()
	else:
		platformer_sprite.set_frame(13)
		platformer_sprite.animation_paused = true
		platformer_sprite.character_platformer_animation.stop()
		death_freeze_timer.start()
		get_tree().set_pause(true)

func _on_DeathFreezeTimer_timeout() -> void:
	die()

func die():
	current_hp = 0
	#Tell the scene that the player has died
	emit_signal('player_die')
	
	if not is_fell_into_pit:
		emit_signal('player_die_normally')
	
	#Play death sound
	FJ_AudioManager.sfx_character_player_die.play()
	
	#Reset to initial palette, prevents weapon energy palette glitch
	CURRENT_PALETTE_STATE = 0
	update_platformer_sprite_color_palettes(true)
	
	#Stop everything
	#Hide player from view and disable process
	set_player_disappear(true)
	
	get_tree().set_pause(false)

#Spawn coins particle 
#Called by Level.
func spawn_death_coins(var lost_amount):
	if lost_amount == 0 :
		return
	
	var coin_inst = coin_particles.instance()
	get_parent().add_child(coin_inst)
	coin_inst.amount = clamp(lost_amount, 0, 150)
	coin_inst.global_position = self.global_position
	
	print("Player(Spawn_death_coins): Coin lost: ", + currency_manager.coin_lost)

func _on_tree_exiting():
	player_stats.current_hp = current_hp

func set_control_enable(enabled : bool):
	pf_bhv.CONTROL_ENABLE = enabled
	
func set_control_enable_from_cutscene(enabled : bool):
	pf_bhv.CONTROL_ENABLE = enabled
	self.is_cutscene_mode = enabled


func _on_leveled_up():
	heal_to_full_hp()

#Disappear from playable area.
#Collision detections, kinematic behaviours.
func set_player_disappear(var set : bool) -> void:
	set_process(!set)
	pf_bhv.INITIAL_STATE = !set #Platformer's Behaviour.
	invis_timer.paused = set
	visible = !set
	collision_shape.call_deferred("set_disabled", set)
	area_collision.call_deferred("set_disabled", set)

#Start transition between screens. This is done by event.
func start_screen_transition(normalized_direction : Vector2, duration : float, reset_vel_x : bool, reset_vel_y : bool, start_delay : float, transit_distance : float):
	var transit_add_pos : Vector2
	
	if normalized_direction == Vector2.RIGHT:
		transit_add_pos.x = transit_distance
	if normalized_direction == Vector2.LEFT:
		transit_add_pos.x = -transit_distance
	if normalized_direction == Vector2.UP:
		transit_add_pos.y = -transit_distance
		pf_bhv.jump_start(false) #Force jump up without checking conditions.
	if normalized_direction == Vector2.DOWN:
		transit_add_pos.y = transit_distance
	
	transition_tween.interpolate_property(
		self,
		'position',
		self.position,
		self.position + transit_add_pos,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		start_delay
	)
	transition_tween.start()
	
	pf_bhv.INITIAL_STATE = false
	platformer_sprite.animation_paused = true
	
	if reset_vel_x:
		pf_bhv.velocity.x = 0
		stop_sliding()
	if reset_vel_y:
		pf_bhv.velocity.y = 0
		stop_sliding()
	
	invis_timer.paused = true
	taking_damage_timer.paused = true

#After screen transiting has completed
func _on_TransitionTween_tween_all_completed() -> void:
	platformer_sprite.animation_paused = false
	pf_bhv.INITIAL_STATE = true
	invis_timer.paused = false
	taking_damage_timer.paused = false

#Collision checks goes here.
func _on_PlatformerBehavior_collided(kinematic_collision_2d : KinematicCollision2D) -> void:
	var collider = kinematic_collision_2d.collider
	
	if collider is DeathSpike:
		player_take_damage(collider.contact_damage)

#Plays jumping sound
func _on_PlatformBehavior_jumped_by_keypress() -> void:
#	FJ_AudioManager.sfx_character_jump.play()
	pass


func _on_PlatformBehavior_landed() -> void:
	FJ_AudioManager.sfx_character_land.play()
	is_cancel_holding_jump_allowed = true

#Regains control when timer of being knocked back is out.
func _on_TakingDamageTimer_timeout() -> void:
	pf_bhv.CONTROL_ENABLE = true
	platformer_sprite.is_taking_damage = false
	taking_damage_slide_pos = 0 #Reset
	is_taking_damage = false
	
	#Stops flashing animation.
	damage_sprite_ani.play("StopFlashin")

func start_sliding():
	slide_collision_shape.set_deferred("disabled", false)
	collision_shape.set_deferred("disabled", true)
	platformer_sprite.is_sliding = true
	is_sliding = true
	slide_remaining = SLIDE_FRAME
	
	#Create slide effect
	var inst_slide_effect = slide_dust_effect.instance()
	get_parent().add_child(inst_slide_effect)
	inst_slide_effect.global_position = slide_dust_pos.global_position
	inst_slide_effect.scale.x = platformer_sprite.scale.x
	
	#Update player's damage hitbox
	area_slide_collision.set_disabled(false)
	area_collision.set_disabled(true)


func stop_sliding(var force_stop : bool = false):
	#If the collision would occur while stopping slide.
	if test_normal_check_collision() and !force_stop:
		 return
	
	slide_collision_shape.set_deferred("disabled", true)
	collision_shape.set_deferred("disabled", false)
	platformer_sprite.is_sliding = false
	is_sliding = false
	slide_remaining = -10
	
	#Update player's damage hitbox
	area_slide_collision.set_disabled(true)
	area_collision.set_disabled(false)

func test_normal_check_collision(vel_rel := Vector2(0, -1)) -> bool:
	var result : bool
	var last_collision_shape : bool = collision_shape.disabled
	var last_slide_collision_shape : bool = slide_collision_shape.disabled
	
	collision_shape.disabled = false
	slide_collision_shape.disabled = true
	result = test_move(self.get_transform(), vel_rel)
	collision_shape.disabled = last_collision_shape
	slide_collision_shape.disabled = last_slide_collision_shape
	
	return result

func test_slide_check_collision(vel_rel := Vector2(0, -1)) -> bool:
	var result : bool
	var last_collision_shape : bool = collision_shape.disabled
	var last_slide_collision_shape : bool = slide_collision_shape.disabled
	
	collision_shape.disabled = true
	slide_collision_shape.disabled = false
	result = test_move(self.get_transform(), vel_rel)
	collision_shape.disabled = last_collision_shape
	slide_collision_shape.disabled = last_slide_collision_shape
	
	return result

func update_platformer_sprite_color_palettes(force_update : bool = false):
	_update_current_character_palette_state(force_update)
	
	platformer_sprite.palette_sprite.primary_sprite.modulate = global_var.current_player_primary_color
	platformer_sprite.palette_sprite.second_sprite.modulate = global_var.current_player_secondary_color
	platformer_sprite.palette_sprite.outline_sprite.modulate = global_var.current_player_outline_color

func _update_current_character_palette_state(force_update : bool = false):
	if player_character_data_res == null:
		return
	if (!pf_bhv.INITIAL_STATE or !pf_bhv.CONTROL_ENABLE) and !force_update:
		return
	
	if player_character_data_res is CharacterData:
		match CURRENT_PALETTE_STATE:
			0:
				global_var.current_player_primary_color = Color(player_character_data_res.primary_color)
				global_var.current_player_secondary_color = Color(player_character_data_res.secondary_color)
				global_var.current_player_outline_color = Color(player_character_data_res.outline_color)
			1:
				global_var.current_player_primary_color = Color(player_character_data_res.primary_color)
				global_var.current_player_secondary_color = Color(player_character_data_res.secondary_color)
				global_var.current_player_outline_color = Color(player_character_data_res.outline_color_charge1)
			2:
				global_var.current_player_primary_color = Color(player_character_data_res.primary_color)
				global_var.current_player_secondary_color = Color(player_character_data_res.secondary_color)
				global_var.current_player_outline_color = Color(player_character_data_res.outline_color_charge2)
			3:
				global_var.current_player_primary_color = Color(player_character_data_res.primary_color)
				global_var.current_player_secondary_color = Color(player_character_data_res.secondary_color)
				global_var.current_player_outline_color = Color(player_character_data_res.outline_color_charge3)
			4:
				global_var.current_player_primary_color = Color(player_character_data_res.secondary_color)
				global_var.current_player_secondary_color = Color(player_character_data_res.outline_color)
				global_var.current_player_outline_color = Color(player_character_data_res.primary_color)
			5:
				global_var.current_player_primary_color = Color(player_character_data_res.outline_color)
				global_var.current_player_secondary_color = Color(player_character_data_res.primary_color)
				global_var.current_player_outline_color = Color(player_character_data_res.secondary_color)

func update_player_sprite_texture():
	if player_character_data_res == null:
		return
	
	if player_character_data_res is CharacterData:
		platformer_sprite.set_texture(player_character_data_res.character_spritesheet)

func play_teleport_in_sound():
	FJ_AudioManager.sfx_character_teleport_in.play()

func play_teleport_out_sound():
	FJ_AudioManager.sfx_character_teleport_out.play()

