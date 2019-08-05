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

export(NodePath) var level_path
export(NodePath) var game_gui_path
export(NodePath) var tilemap_path

#Player's stats
const HP_BASE : int = 28
const MP_BASE : int = 20
const DAMAGE_BASE = 2
const DEFAULT_INVIS_TIME : float = 1.5
const ATTACK_HOTKEY = 'game_action'
const ATTACK_HOTKEY_1 = 'game_hotkey1'
const TAKING_DAMAGE_SLIDE_LEFT := -20
const TAKING_DAMAGE_SLIDE_RIGHT := 20

#Current stats.
var current_hp = HP_BASE
var current_mp = MP_BASE
var max_hp = 28
var max_mp = 20
var attack_power = DAMAGE_BASE
var is_invincible = false
var is_attack_ready = true
var attack_cooldown_apply_time = 0.01
var attack_type = 0 #0:By Pressing action button, 1:Holding action button
var is_cutscene_mode = false #When true, player won't take damage while in cutscene
var is_cancel_holding_jump_allowed = true
var is_taking_damage = false
var taking_damage_slide_pos := 0 #Use only x-axis!

#Player's child nodes
onready var pf_bhv := $PlatformBehavior as FJ_PlatformBehavior2D
onready var area = $Area2D
onready var area_collision := $Area2D/CollisionShape2D as CollisionShape2D
onready var collision_shape := $CollisionShape2D as CollisionShape2D
onready var platformer_sprite = $PlatformerSprite
onready var animation_player = $AnimationPlayer
onready var pivot_shoot = $Pivots/Shoot
onready var attack_cooldown_timer = $AttackCooldownTimer
onready var invis_timer = $InvincibleTimer
onready var taking_damage_timer = $TakingDamageTimer
onready var transition_tween := $TransitionTween as Tween
onready var damage_sprite = $DamageSprite
onready var damage_sprite_ani = $DamageSprite/Ani

onready var level_camera := get_node_or_null("/root/Level/Camera2D") as Camera2D

onready var global_var = get_node("/root/GlobalVariables")
onready var tile_map = get_node("/root/Level/TileMap")
onready var checkpoint_manager = get_node("/root/CheckpointManager")
onready var currency_manager = get_node("/root/CurrencyManager")
onready var player_stats = get_node("/root/PlayerStats")

#Preloading objects... Ex: Bullets.
var proj_classicBullet = preload("res://Entities/PlayerProjectile/PlayerProjectile_MegaBuster.tscn")
var dmg_counter = preload("res://GUI/DamageCounter.tscn")
var explosion_effect = preload("res://Entities/Effects/Explosion/Explosion.tscn")
var coin_particles = preload("res://Entities/Effects/Particles/CoinParticles.tscn")
var vulnerable_effect = preload("res://Assets_ReleaseExcluded/Sprites/Effects/VulnerableEffect.tscn")
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

func _process(delta):
	"""
	--------Movement--------
	"""
	set_vflip_by_keypress()
	press_attack_check()
	check_for_area_collisions()
	crush_check() #Check if player is crushed
	check_holding_jump_key()
	check_taking_damage()

#Check if jump key is holding while in the air.
#Otherwise, resets velocity y
func check_holding_jump_key():
	if is_cancel_holding_jump_allowed:
		if !Input.is_action_pressed("game_jump") and pf_bhv.velocity.y < 0 and pf_bhv.on_air_time > 0:
			pf_bhv.velocity.y = 0
			is_cancel_holding_jump_allowed = false

func set_starting_location():
	#First, get data from checkpoint manager.
	var is_default_location = checkpoint_manager.saved_player_position == Vector2(0, 0)
	#Update checkpoint's position if not set.
	if !checkpoint_manager.has_checkpoint():
		checkpoint_manager.update_checkpoint_position(global_position, get_tree().get_current_scene().get_filename(), global_var.current_view)
		print(self.name, ': No checkpoint available. Automatically updated.')
	
	if STARTING_LOCATION == 0: #Auto
		if !is_default_location:
			global_position = checkpoint_manager.saved_player_position
	if STARTING_LOCATION == 2: #Never (Unsafe)
		global_position = checkpoint_manager.saved_player_position
		if is_default_location:
			push_warning(str(self) + str(name) + ': Default starting location for a player is not configured!')
	
	#If player died last time, checkpoint will be used
	#and set current player's position.
	if player_stats.is_died:
		global_position = checkpoint_manager.current_checkpoint_position

func set_starting_stats():
	#When player enters scene for the first time (Enter level, died last time),
	#the player's health will be restored.
	#Otherwise, set current hp to previous health from last scene.
	if player_stats.restore_hp_on_load:
		player_stats.restore_hp_on_load = false
	else:
		current_hp = player_stats.current_hp

func _on_PlatformerBehavior_fell_into_pit() -> void:
	#Spawn damage counter.
	current_hp = 0
	#Update GUI
	get_owner().update_game_gui_health()
	player_death()

func set_vflip_by_keypress():
	if pf_bhv.walk_left:
		platformer_sprite.flip_h = true
	if pf_bhv.walk_right:
		platformer_sprite.flip_h = false

func press_attack_check():
	#Character will start to shoot/attack when the player pressed "action key"
	#To be able to attack, all of the following conditions must be met:
	#  -There is a keypress stroke.
	#  -Attack is not in cooldown and must be ready (Rapid firing is the exception).
	if is_attack_ready:
		if attack_type == 0:
			if Input.is_action_just_pressed(ATTACK_HOTKEY):
				start_launching_attack()
		else:
			if Input.is_action_pressed(ATTACK_HOTKEY):
				attack_cooldown_timer.start(attack_cooldown_apply_time)
				is_attack_ready = false
				start_launching_attack()
			if Input.is_action_pressed(ATTACK_HOTKEY_1):
				attack_cooldown_timer.start(attack_cooldown_apply_time)
				is_attack_ready = false
				start_launching_attack_skill()

func start_launching_attack() -> void:
	if get_total_projectile_on_screen_count() > 2:
		return
	
	if !pf_bhv.CONTROL_ENABLE:
		return
	
	var bullet = proj_classicBullet.instance()
	get_parent().add_child(bullet) #Deploy projectile from player.
	
	#-----HARD CODED------
	var hvlip_shift_pivot_offset : Vector2 = Vector2(0, 0)
	if platformer_sprite.flip_h:
		hvlip_shift_pivot_offset.x = -pivot_shoot.position.x
	bullet.position = pivot_shoot.global_position + (hvlip_shift_pivot_offset * 2)
	#--END OF HARD CODED--
	bullet.bullet_behavior.angle_in_degrees = 180.0 if platformer_sprite.flip_h else 0.0
	
	#Calculate damage
	var total_damage = 0
	total_damage = DAMAGE_BASE + bullet.DAMAGE_POWER
	bullet.DAMAGE_POWER = total_damage #Final damage output
	
	
	#Play sound
	FJ_AudioManager.sfx_combat_buster.play()
	
	#Emit signal
	emit_signal("launched_attack")

func get_total_projectile_on_screen_count() -> int:
	return get_tree().get_nodes_in_group("PlayerProjectile").size()

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
					update_gui("update_coin")
				elif coin.is_diamond():
					#Add diamond PERMANENTLY to your bank!!
					currency_manager.game_diamond += coin.COIN_VALUE
					#Update coin GUI too! Yeah! You've made a progress.
					update_gui("update_diamond")
				#Destroy coin
				coin.player_collected_coin()

#When ANY kind of 'area' collides with player (once),
#Do anything below here.
func _on_area_entered(body):
	pass #CURRENTLY DOING NOTHING

func player_take_damage(damage_amount : int, repel_player : bool = false, repel_position : Vector2 = Vector2(0, 0), repel_power : int = 300, apply_new_invis : bool = false, apply_new_invis_time : float = 0.1):
	if is_invincible or is_cutscene_mode:
		return
	
	#TODO: Shock guard item..
	#Remove these if you don't want HP stops at 1.
	#(Reference from 'Shock Guard' item)
	if current_hp > 1:
		if current_hp - damage_amount < 1:
			damage_amount = current_hp - 1
			FJ_AudioManager.sfx_ui_game_start.play()
	
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
	damage_sprite_ani.play("Flashing")
	
	#Spawn damage counter
	spawn_damage_counter(damage_amount)
	
	#Spawn vulnerable effect
	spawn_vulnerable_effect()
	
	#Check for death
	if current_hp <= 0:
		player_death()
		emit_signal('player_die_normally')
		
	else:
		FJ_AudioManager.sfx_character_player_damage.play()
		animation_player.play("Invincible")
	
	#Update GUI
	update_gui("update_gui_bar")
	
	is_taking_damage = true

func check_taking_damage():
	if is_taking_damage:
		pf_bhv.velocity.x = taking_damage_slide_pos

func change_player_current_hp(var amount):
	current_hp += amount
	if current_hp < 0:
		current_hp = 0
		player_death()
	if current_hp > max_hp:
		current_hp = max_hp
	
	#Update GUI
	update_gui("update_gui_bar")

func heal_to_full_hp():
	current_hp = max_hp
	update_gui("update_gui_bar")

#When the invincible's timer runs out, player will be able to get hurt again.
func _on_invis_timer_timeout():
	is_invincible = false
	animation_player.stop()
	platformer_sprite.visible = true #Due to animation glitch, this will surely fix it.

func repel_player():
	pf_bhv.velocity.x = 0
	pf_bhv.velocity.y = -50
	if platformer_sprite.flip_h:
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
	var eff = vulnerable_effect.instance()
	get_parent().add_child(eff)
	eff.global_position = self.global_position

#When the player's health drops below zero, player won't be able to
#continue their journey.
#Why? The character can die... but that won't affect
#the main story. You may get a game over screen or lost 1UP.
func player_death():
	current_hp = 0
	#Tell the scene that the player has died
	emit_signal('player_die')
	
	#Create Explosion effect
	var effect = explosion_effect.instance()
	effect.position = self.global_position
	get_parent().add_child(effect)
	
	#Play death sound
	FJ_AudioManager.sfx_character_player_die.play()
	
	#Shake the camera (if exists)
	if level_camera != null:
		level_camera.shake_camera(0.5, 100, 30)
	
	#Restore hp on scene load. Because we wanted player to restore health
	#after the player is respawned.
	player_stats.restore_hp_on_load = true
	
	player_stats.is_died = true #PLAYER IS DEAD!
	
	#Stop everything
	#Hide player from view and disable process
	set_player_disappear(true)
	
	#Loses one up!
	get_node("/root/GlobalVariables").one_up -= 1

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

#For check if player is stuck (suffocated) in the wall.
func crush_check():
	if area.overlaps_body(tile_map):
		#Spawn damage counter.
		spawn_damage_counter(current_hp)
		current_hp = 0
		#Update GUI
		update_gui("update_gui_bar")
		player_death()

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

#Call GameGui to update bar or some sort...
func update_gui(var method_name : String) -> bool:
	if get_node_or_null(game_gui_path) != null:
		if get_node(game_gui_path).has_method(method_name):
			get_node(game_gui_path).update_gui_bar()
			return true
		else:
			push_warning(
				str(
					self.name,
					": Method ",
					method_name,
					" not found! Nothing was done."
				)
			)
	
	return false

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
	collision_shape.call_deferred("set_disabled", true)
	area_collision.call_deferred("set_disabled", true)
	platformer_sprite.animation_paused = true
	
	if reset_vel_x:
		pf_bhv.velocity.x = 0
	if reset_vel_y:
		pf_bhv.velocity.y = 0
	
	invis_timer.paused = true
	taking_damage_timer.paused = true

#After screen transiting has completed
func _on_TransitionTween_tween_all_completed() -> void:
	collision_shape.call_deferred("set_disabled", false)
	area_collision.call_deferred("set_disabled", false)
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
