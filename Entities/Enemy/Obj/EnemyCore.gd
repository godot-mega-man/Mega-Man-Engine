extends KinematicBody2D
class_name EnemyCore

signal taken_damage(value, target, player_proj_source)
signal dropped_coin(value, count)
signal damage_counter_released(value, target)
signal slain(target)
signal despawned(by_dying)

export(Array, NodePath) onready var damage_area_nodes

#Enemy's statistics
export var LEVEL = 1 #Tell how physically strong enemy is.
export var HP = 40 #Initial maximum hit points.
export var HP_REGENERATION_RATE = 0.25 #Regenerate hit points over time.
export var HP_REGEN_TYPE = 0 #INTERVAL = slowly regen in interval, CONSTANTLY = ignores regen interval
export var HP_REGEN_INTERVAL = 1.0 #Interval health regeneration mode only.
export var CAN_INTERRUPT_HP_REGENERATION_ON_ATTACKS = true #Begins delaying hp regen when attacks or attacked.
export var HP_REGEN_DELAY = 2.5 #Delays before starting regenerating health after damage is taken or attacks.

export var IS_IMMUNE_TO_DEATH = false #When true, enemy cannot die normally.
export var IS_INVULNERABLE = false #When true, enemy won't take any damage from any sources.
export var INVISIBILITY_TIME = 0.0 #Cooldown before taking another damage. While on cooldown, damage taken from all source are ignored.
export var INVISIBILITY_BLINKER = true #While invisibility time is on, the sprite will be blink.
export var DAMAGE_TAKEN_RATE_RATIO = 1.0 #Percentage how much damage enemy takes.
export var DAMAGE_TAKEN_MINIMUM = 1 #Minimum damage taken from player's projectile
export var DEATH_SHAKE_STRENGTH = 3
export var EAT_PLAYER_PROJECTILE = true #When on, enemy will attempt to destroy the player's bullet.

export var STRENGTH = 3 #Amount of damage applies to player when collided.
export var REPEL_PLAYER_UPON_CONTACT = true #Repel player away when damage is applied
export var REPEL_STRENGTH = 300 #Strength to push player away when collided with enemy.
export var CAN_APPLY_DAMAGE = true #If false, player can collide with enemy without taking damage.
export var APPLY_DAMAGE_APPLY_INVIS_TIME_OVERRIDE = false #If on, player will have a custom invisibility time after damage is taken.
export var APPLY_DAMAGE_APPLY_INVIS_TIME = 0.1 #How long the player will be able to take damage again.

export var DROP_COIN = true #Dis/enable Coins drop from enemy
export var DROP_COIN_AMOUNT = 1 #Amount of coin drop from enemy when dies.
export var DROP_COIN_AMOUNT_VARIANCE = 0.2 #Randomize value of the coin by percentage.
export var DROP_COIN_COUNT = 1 #Number of coin drop from enemy when dies.
export var DROP_COIN_CHANCE = 1 #Given a chance for the enemy to drop coins.
export var DROP_COIN_CYCLE_COUNT = 3 #Only if enemy do not die permanently. -1 for unlimited drop.

export var EXP_REWARD = 1 #Amount of given experience points.

export var ACTIVE_ON_SCREEN = Vector2(32, 32) #Active/inactive when the enemy is visible on screen by pixels offset
export var PERMA_DEATH_SCENE = true #Die permanently WITHIN SCENE ONLY instead of respawning everytime enemy dies
export var PERMA_DEATH_LEVEL = false #Die permanently within current level. Useful with bosses and mini-bosses
export var IS_A_CLONE = false

#Child nodes:
onready var anim = $AnimationPlayer
onready var sprite = $Sprite
onready var platform_collision_shape = $PlatformCollisionShape2D as CollisionShape2D
onready var damage_area = $DamageArea2D
onready var damage_collision_shape = $DamageArea2D/CollisionShape2D
onready var invis_timer = $InvisTimer
onready var regen_timer = $RegenerationTimer
onready var hp_bar = $HpBar
onready var active_vis_notifier = $ActiveVisNotifier
onready var player_camera = get_node("/root/Level/Iterable/Player/Camera2D")
onready var stackable_dmg_counter_timer = $StackableDmgCounterTimer

onready var audio_manager = $"/root/AudioManager"
onready var global_var = $"/root/GlobalVariables"
onready var fade_screen = $"/root/Level/FadeScreen"
onready var level = get_node("/root/Level")
onready var player_stats = get_node("/root/PlayerStats")

#Temp variables
var current_hp
var is_invul = false #If true, enemy won't take any damage.
var is_regenerating_hp = true
var self_saved_data #USED TO KEEPS DATA FOR RELOADING ITS STATE.
var initialy_inactive = false
var is_fresh_respawn = false
var is_reset_state_called = false #Call once
var is_coin_dropped = false
var total_stacked_damage = 0 #Used in damage counter. Stacking damage for a short brief when constantly taking damage.

#Preloaded scenes
var dmg_counter = preload("res://GUI/DamageCounter.tscn")
var exp_counter = preload("res://GUI/ExpCounter.tscn")
var explosion_effect = preload('res://Entities/Effects/Explosion/Explosion.tscn')
var coin = preload("res://Entities/Coin/Coin1.tscn")
var explosion_particles = preload("res://Entities/Effects/Particles/ExplosionParticles.tscn")

func _ready():
	regen_timer.start(HP_REGEN_INTERVAL) #Uses custom timer value.
	init_temp_variables()
	hp_bar.init_health_bar(0, HP, current_hp)

func set_active(var active = true):
	set_process(active)
	damage_collision_shape.disabled = !active
	self.visible = active

func init_temp_variables():
	current_hp = HP

func _process(delta):
	#If enemy has a constantly regen type,
	#regenerating health overtime
	if HP_REGEN_TYPE == 2 && is_regenerating_hp:
		#Slowly regenerating health over delta time.
		current_hp += HP_REGENERATION_RATE * delta
		normalize_hp()
		hp_bar.update_hp_bar(current_hp) #Update health bar

func _physics_process(delta: float) -> void:
	#Check for my collision that overlapping areas
	_check_for_area_collisions()

func hit_by_player_projectile(var damage : int, var damage_variance : float, var player_proj_source : PlayerProjectile) -> bool:
	var condition : bool #Init a return value
	
	#Check whether damage can be taken.
	# -Not in invis mode.
	# -Not invulnerable
	var can_apply_damage : bool = true
	if IS_INVULNERABLE or is_invul:
		can_apply_damage = false
	
	#Start apply damage if all conditions are met.
	if can_apply_damage:
		var damage_output = calculate_damage_output(damage, damage_variance)
		apply_damage(damage_output)
		emit_signal("taken_damage", damage_output, self as EnemyCore, player_proj_source)
		
		#Play animation "Blink". Blinking sprite indicates that
		#the enemy is taking damage or being invincible.
		if INVISIBILITY_BLINKER: #If on
			if INVISIBILITY_TIME > 0:
				anim.play("Damage_Loop")
			else:
				anim.play("Damage")
		if INVISIBILITY_TIME > 0:
			invis_timer.start(INVISIBILITY_TIME)
			is_invul = true
		
		check_for_death()
		
		#Damage is applied. Set value to true.
		condition = true
	else:
		condition = false
	
	return condition

func _check_for_area_collisions():
	for i in damage_area_nodes:
		var areas = get_node(i).get_overlapping_areas()
		
		for j in areas:
			#When player collides with enemy,
			#The character will take damage and will become invincible
			#for a short amount of time.
			#When invincible time is out, the player will be able to
			#take damage again.
			var player = j.get_owner()
			if player != null && player is Player:
				if CAN_APPLY_DAMAGE and !player.is_invincible and !player.is_cutscene_mode:
					#Define call method
					var call_method = "player_take_damage"
					
					#Get necessary information of enemy.
					var enemy_parameters = [
						STRENGTH,
						REPEL_PLAYER_UPON_CONTACT,
						get_global_position(),
						REPEL_STRENGTH,
						APPLY_DAMAGE_APPLY_INVIS_TIME_OVERRIDE,
						APPLY_DAMAGE_APPLY_INVIS_TIME_OVERRIDE
					]
					
					if player.has_method(call_method):
						player.callv(call_method, enemy_parameters)
			
			#If the bullet detects that it collides with Enemy
			var projectile = j
			if projectile != null && projectile is PlayerProjectile:
				var bit_flag_comparator = BitFlagsComparator.new()
				#Check if bullet is capable of being destroyed at the end
				#Bullet may not get destroyed if enemy is being invincible.
				var destroy_bullet_at_the_end = bit_flag_comparator.is_bit_enabled(projectile.DESTROY_ON_COLLIDE_TYPE, 0) && !self.is_invul && EAT_PLAYER_PROJECTILE
				var can_bullet_hit = true #Init
				
				#Check if bullet is unable to hit (ignore)
				if (projectile.HIT_ONCE_PER_FRAME and projectile.is_hitted) or (!self.can_be_damaged()):
					can_bullet_hit = false
				elif projectile.is_reflected:
					can_bullet_hit = false
				elif get_node(i).has_node("ProjectileReflector"):
					var proj_reflector = get_node(i).get_node("ProjectileReflector") as ProjectileReflector
					var reflected = proj_reflector.do_reflect()
					
					#Start telling player's projectile that its bullet has been reflected.
					if reflected:
						projectile.reflected()
						can_bullet_hit = false
						destroy_bullet_at_the_end = false
				
				if can_bullet_hit:
					if projectile.apply_damage:
						hit_by_player_projectile(projectile.DAMAGE_POWER, projectile.DAMAGE_VARIANCE, projectile)
					projectile.emit_signal("hit_enemy", projectile)
					projectile.is_hitted = true
				
				#Destroy projectile if hit an enemy.
				if destroy_bullet_at_the_end:
					projectile.queue_free_start()

#Calculates damage, return the damage output value.
func calculate_damage_output(var raw_damage : int, var damage_variance : float = 0) -> float:
	var damage_result = 0
	
	damage_result += raw_damage
	#Multiply damage taken ratio.
	damage_result = round(damage_result * DAMAGE_TAKEN_RATE_RATIO)
	#Damage vary by percentage (range 0 - 1).
	damage_result = round(damage_result * (1 + rand_range(-damage_variance, damage_variance)))
	#Damage can't go below minimum.
	#Ex: If damage is -25, it's finalized as 1 by default.
	if damage_result < DAMAGE_TAKEN_MINIMUM:
		damage_result = DAMAGE_TAKEN_MINIMUM
	
	return damage_result

#Use calculated damage value to apply damage to enemy.
#Ignores invisibility time.
func apply_damage(var calculated_damage, var do_halt_hp_regen = true, var update_hp_bar = true, var spawn_damage_counter = true):
	#Subtracting HP.
	current_hp -= calculated_damage
	
	#Halt HP regeneration. The enemy will have to wait
	#to be able to start regenerating health again.
	if do_halt_hp_regen:
		interrupt_health_regen()
	
	#Spawn damage counter on the screen.
	if spawn_damage_counter:
		start_stackable_damage_counter(calculated_damage)
	#Update health bar
	if update_hp_bar:
		hp_bar.update_hp_bar(current_hp)

func can_be_damaged() -> bool:
	if (
		(current_hp <= 0 and !IS_IMMUNE_TO_DEATH) or
		is_invul or
		!EAT_PLAYER_PROJECTILE
	):
		return false
	
	return true

func _on_InvisTimer_timeout():
	is_invul = false
	anim.stop()
	sprite.visible = true

#Check if hit points exceeds limit, normalize it.
#Optional to cut decimal hp value.
func normalize_hp(cut_float_value : bool = false) -> void:
	if current_hp > HP: #Normalize hp
		current_hp = HP
	if current_hp < 0: #Can't drop below zero. In case enemy is immune to death
		current_hp = 0
	if cut_float_value: #Round down hp (Optional)
		floor(current_hp)

#Restores hit points
func heal(amount_of_hp_to_restore : float):
	current_hp += amount_of_hp_to_restore
	normalize_hp()

#Check whether this enemy can die.
#If its hit points drop below zero, DIE!~
func check_for_death():
	if !IS_IMMUNE_TO_DEATH && current_hp <= 0:
		audio_manager.sfx_enemy_collapse.play()
		audio_manager.sfx_enemy_damage.stop()
		die()
	else:
		audio_manager.sfx_enemy_damage.play()
	audio_manager.sfx_shot.stop()

func die():
	#Create death animation effect
	var effect = explosion_effect.instance()
	effect.position = self.global_position
	get_parent().add_child(effect)
	
	#Drop coin when dies
	drop_coin_start()
	
	#Awards player experience points.
	if EXP_REWARD > 0:
		earn_exp()
		spawn_exp_counter(EXP_REWARD)
	
	#Shake Camera
	player_camera.shake_camera(0.3, 50, DEATH_SHAKE_STRENGTH)
	
	#Start queue freeing, tell the method that this obj is slain.
	call_deferred('queue_free_start', true)
	
	#Emit signal
	emit_signal("slain", self)

#Start queue freeing.
func queue_free_start(by_dying : bool):
	if !is_reset_state_called: #Called once
		
		is_reset_state_called = true
		
		emit_signal("despawned", by_dying)
		
		queue_free()

#Start stacking damage counter to an enemy before spawning the text.
#When the enemy is constantly taking damage in a short brief,
#the damage value are added up.
#After a while enemy not taking damage, damage counter will then pop out.
func start_stackable_damage_counter(value_add : float):
	#Stack!
	total_stacked_damage += value_add
	#Check whether enemy is dead.
	#If that so, spawn damage counter immediately.
	if current_hp <= 0 and !IS_IMMUNE_TO_DEATH:
		spawn_damage_counter(total_stacked_damage)
	else:
		stackable_dmg_counter_timer.start()
func _on_StackableDmgCounterTimer_timeout():
	#Spawn damage counter.
	spawn_damage_counter(total_stacked_damage)

func spawn_damage_counter(damage, offset : Vector2 = Vector2(0, 0)):
	var dmg_text = dmg_counter.instance() #Instance DamageCounter
	dmg_text.global_position = self.global_position #Set position to enemy
	dmg_text.position += offset #Offset
	get_parent().add_child(dmg_text) #Spawn
	dmg_text.set_float_as_text(damage) #Set child node's text
	
	#Reset total stacked damage value to zero.
	total_stacked_damage = 0
	
	emit_signal("damage_counter_released", damage, self)

func spawn_exp_counter(damage, offset : Vector2 = Vector2(0, 0)):
	var dmg_text = exp_counter.instance() #Instance DamageCounter
	dmg_text.get_node('Label').text = str(damage) #Set child node's text
	dmg_text.global_position = self.global_position #Set position to enemy
	dmg_text.position += offset #Offset
	dmg_text.get_node('Label').add_color_override("font_color", Color(0, 0.7, 1)) #Set text color to cyan
	#Make the text float up
	dmg_text.GRAVITY = 60
	dmg_text.RANDOM_X_SWAY = 0
	dmg_text.RANDOM_Y_GEYSER_MAX = 90
	dmg_text.RANDOM_Y_GEYSER_MIN = 90
	dmg_text.stay_time = 1.5
	get_parent().add_child(dmg_text) #Spawn

func drop_coin_start():
	#If this enemy do not drop coin upon death... Do nothing.
	if !DROP_COIN:
		return
	#If cycle's count runs out, coin won't be dropped.
	if DROP_COIN_CYCLE_COUNT == 0:
		return
	
	var chance = rand_range(0, 1) #Chance to drop coins
	#Check for drop chance
	if chance < DROP_COIN_CHANCE:
		call_deferred("spawn_coins_by_amount", DROP_COIN_AMOUNT, DROP_COIN_COUNT, DROP_COIN_AMOUNT_VARIANCE)

func earn_exp(value : int = EXP_REWARD):
	#Earn exp.
	player_stats.experience_point += value
	#Update GUI
	level.update_game_gui_exp()

func spawn_coins_by_amount(var value : int = 1, var count : int = 1, var variance : float = 0.2):
	for i in count:
		var coin_inst = coin.instance()
		get_parent().call_deferred("add_child", coin_inst)
		coin_inst.ITEM_TYPE = 0 #Coin
		coin_inst.global_position = self.global_position
		coin_inst.COIN_VALUE = round(value * (1 + rand_range(-DROP_COIN_AMOUNT_VARIANCE, DROP_COIN_AMOUNT_VARIANCE)))# Set value and variance the value.
	
	emit_signal("dropped_coin", value, count)

#INTERVAL regeneration type only! When it's time to regenerate health,
#restores amount of hp and let the timer automatically start again.
#After regeneration process, it will completely stop regenerating
#if enemy is at full health.
func _on_RegenerationTimer_timeout():
	is_regenerating_hp = true
	if HP_REGEN_TYPE == 1:
		heal(HP_REGENERATION_RATE)
		regen_timer.wait_time = HP_REGEN_INTERVAL
		if !is_at_full_health():
			regen_timer.start()
		else:
			is_regenerating_hp = false
	hp_bar.update_hp_bar(current_hp) #Update health bar

func interrupt_health_regen():
	#Halt HP regeneration. The enemy will have to wait
	#to be able to start regenerating health again.
	if CAN_INTERRUPT_HP_REGENERATION_ON_ATTACKS:
		return
	
	if !is_regenerating_hp: #For interval regen case. While hp is not regenerating, start it anyway.
		is_regenerating_hp = true
		regen_timer.start()

func is_at_full_health():
	return current_hp >= HP

#When enemy leaves the screen, the enemy disappear.
func _on_ActiveVisNotifier_screen_exited():
	#Reset to initial state for respawning
	queue_free_start(false)