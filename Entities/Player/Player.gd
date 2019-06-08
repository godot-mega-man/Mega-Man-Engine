extends KinematicBody2D
class_name Player

signal player_die
signal launched_attack

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
const HP_BASE : int = 30
const MP_BASE : int = 20
const DAMAGE_BASE = 3
const DEFAULT_INVIS_TIME : float = 1.0
const ATTACK_HOTKEY = 'game_action'
const ATTACK_HOTKEY_1 = 'game_hotkey1'

#Current stats.
var current_hp = HP_BASE
var current_mp = MP_BASE
var max_hp = 30
var max_mp = 20
var attack_power = DAMAGE_BASE
var is_invincible = false
var is_attack_ready = true
var attack_cooldown_apply_time = 0.15
var attack_type = 1 #0:By Pressing action button, 1:Holding action button
var is_cutscene_mode = false #When true, player won't take damage while in cutscene

#Player's child nodes
onready var platformer_behavior = $PlatformerBehavior
onready var area = $Area2D
onready var area_collision = $Area2D/CollisionShape2D
onready var camera = $Camera2D
onready var collision_shape = $CollisionShape2D
onready var platformer_sprite = $PlatformerSprite
onready var animation_player = $AnimationPlayer
onready var pivot_shoot = $Pivots/Shoot
onready var attack_cooldown_timer = $AttackCooldownTimer
onready var invis_timer = $InvincibleTimer

onready var audio_manager = get_node("/root/AudioManager")
onready var global_var = get_node("/root/GlobalVariables")
onready var tile_map = get_node("/root/Level/TileMap")
onready var checkpoint_manager = get_node("/root/CheckpointManager")
onready var currency_manager = get_node("/root/CurrencyManager")
onready var player_stats = get_node("/root/PlayerStats")

#Preloading objects... Ex: Bullets.
var proj_classicBullet = preload("res://Entities/PlayerProjectile/PlayerProjectile_ClassicBullet.tscn")
var dmg_counter = preload("res://GUI/DamageCounter.tscn")
var explosion_effect = preload("res://Entities/Effects/Explosion/Explosion.tscn")
var coin_particles = preload("res://Entities/Effects/Particles/CoinParticles.tscn")

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
	check_falling_into_pit()
	set_vflip_by_keypress()
	press_attack_check()
	check_for_area_collisions()
	suicide_check()
	check_warping_around_left_right() #Warps player around left-right. Defined in the level settings.
	crush_check() #Check if player is crushed

func set_starting_location():
	#First, get data from checkpoint manager.
	var is_default_location = checkpoint_manager.saved_player_position == Vector2(0, 0)
	#Update checkpoint's position if not set.
	if !checkpoint_manager.has_checkpoint():
		checkpoint_manager.update_checkpoint_position(global_position, get_tree().get_current_scene().get_filename())
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

func check_falling_into_pit():
	#If player falls below the edge of the bottom.
	# -May normally die
	# -May wrap upside down
	var WARP_OFFSET = 32
	var limit_bottom = (camera as Camera2D).limit_bottom + WARP_OFFSET
	var limit_top = (camera as Camera2D).limit_top - WARP_OFFSET
	
	if (self as KinematicBody2D).position.y > limit_bottom:
		if get_owner().WARPS_PLAYER_AROUND_UP_DOWN: #If the level allows warping up-down
			(self as KinematicBody2D).position.y = limit_top
		else:
			#Spawn damage counter.
			spawn_damage_counter(current_hp, Vector2(0,-40))
			current_hp = 0
			#Update GUI
			get_owner().update_game_gui_health()
			player_death()

func set_vflip_by_keypress():
	if platformer_behavior.walk_left:
		platformer_sprite.flip_h = true
	if platformer_behavior.walk_right:
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

func suicide_check():
	if Input.is_action_just_pressed("game_hotkey2"):
		if current_hp > 0:
			current_hp = 0
			update_gui("update_gui_bar")
			player_death()

func start_launching_attack() -> void:
	if !platformer_behavior.CONTROL_ENABLE:
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
	audio_manager.sfx_shot.play()
	
	#Emit signal
	emit_signal("launched_attack")

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
	#Subtracting health from damage taken.
	current_hp -= damage_amount
	#Repel player away from the enemy.
	if repel_player:
		repel_player(repel_position, repel_power)
	
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
	
	#Spawn damage counter
	spawn_damage_counter(damage_amount)
	
	#Check for death
	if current_hp <= 0:
		player_death()
	else:
		audio_manager.sfx_player_damage.play()
		animation_player.play("Invincible")
	
	#Update GUI
	update_gui("update_gui_bar")

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

func repel_player(var from : Vector2, var repel_strength : float):
	if from.x < position.x:
		platformer_behavior.velocity.x = repel_strength
	else:
		platformer_behavior.velocity.x = -repel_strength
	
	platformer_behavior.velocity.y = -repel_strength / 2 #Divide is not really environmental friendly! Come on...

func spawn_damage_counter(damage, var spawn_offset : Vector2 = Vector2(0,0)):
	var dmg_text = dmg_counter.instance() #Instance DamageCounter
	get_parent().add_child(dmg_text) #Spawn
	dmg_text.set_float_as_text(damage) #Set child node's text
	dmg_text.global_position = self.global_position #Set position to player
	dmg_text.global_position += spawn_offset #Spawn offset
	dmg_text.get_node('Label').add_color_override("font_color", Color(1,0,0,1))

#When the player's health drops below zero, player won't be able to
#continue their journey.
#Why? The character can die... but that won't affect
#the main story. You may get a game over screen or lost 1UP.
func player_death():
	emit_signal('player_die') #Tell the scene that the player has died
	
	#Stop BGM
	audio_manager.stop_bgm()
	
	
	#Restore hp on scene load. Because we wanted player to restore health
	#after the player is respawned.
	player_stats.restore_hp_on_load = true
	
	player_stats.is_died = true #PLAYER IS DEAD!
	
	audio_manager.set_all_sfx_volume(-80)
	
	#Stop everything
	#Hide player from view and disable process
	get_node("TimescaleTimer").start()
	get_tree().paused = true

#Spawn coins particle 
#Called by Level.
func spawn_death_coins(var lost_amount):
	if lost_amount == 0 :
		return
	
	var coin_inst = coin_particles.instance()
	get_parent().add_child(coin_inst)
	coin_inst.amount = clamp(lost_amount, 0, 150)
	coin_inst.global_position = self.global_position
	
	print("Player(Spawn_death_coins): Coin lost: ", + currency_manager.coin_lost, ", Exp lost: ", player_stats.exp_lost)

func check_warping_around_left_right():
	var WARP_OFFSET = 8
	
	if get_owner().WARPS_PLAYER_LEFT_RIGHT_SIDE:
		#If player is at the edge of the screen at either side,
		#force player to warp around left-right.
		if position.x < camera.limit_left - WARP_OFFSET:
			position.x = camera.limit_right + WARP_OFFSET
		if position.x > camera.limit_right + WARP_OFFSET:
			position.x = camera.limit_left - WARP_OFFSET

func _on_tree_exiting():
	player_stats.current_hp = current_hp

func set_control_enable(enabled : bool):
	self.CONTROL_ENABLE = enabled
	
func set_control_enable_from_cutscene(enabled : bool):
	self.CONTROL_ENABLE = enabled
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
	platformer_behavior.INITIAL_STATE = !set #Platformer's Behaviour.
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

func _on_PlatformerBehavior_landed() -> void:
	audio_manager.sfx_landing.play()
