class_name EnemyCore extends KinematicBody2D


signal taking_damage(value, target, player_proj_source)
signal taken_damage(value, target, player_proj_source)
signal dropped_item(item_data, quantity)
signal dropped_diamond
signal damage_counter_released(value, target)
signal slain(target)
signal despawned(by_dying)
signal dying


enum preset_range_checking_mode {
	Radius, Horizontal, Vertical
}

#Dead sound effect
enum dead_sfx {
	COLLAPSE,
	LARGE_EXPLOSION,
	LARGE_EXPLOSION_MM3,
	NONE
}

const PICKUP_NONE = ""
const PICKUP_WEAPON_ENERGY_SMALL = "WeaponEnergySmall"
const PICKUP_LIFE_ENERGY_SMALL = "LifeEnergySmall"
const PICKUP_WEAPON_ENERGY_LARGE = "WeaponEnergyLarge"
const PICKUP_LIFE_ENERGY_LARGE = "LifeEnergyLarge"
const PICKUP_LIFE = "Life"

export (Texture) var sprite_preview_texture

export (Array, NodePath) onready var damage_area_nodes

export (PackedScene) var explosion_effect

export (dead_sfx) var death_sound = dead_sfx.COLLAPSE

#Database
export (float) var contact_damage = 1 #Deals damage when collided with player.
export var death_immunity = false #When true, enemy cannot die normally.
export var can_hit = true #When true, enemy won't take any damage from any sources.
export var damage_taken_minimum = 0 #Minimum damage taken from player's projectile
export var eat_player_projectile = true #When on, enemy can attempt to destroy the player's bullet.
export var can_damage = true #If false, player can collide with enemy without taking damage.
export var damage_custom_invis_enabled = false #If on, player will have a custom invisibility time after damage is taken.
export var damage_custom_invis_timer = 0.1 #How long the player will be able to take damage again.
export (int, 1, 2147483647) var hit_points_base = 40 #Initial maximum hit points.
export var repel_player_enabled = true #Repel player away when damage is applied
export var repel_power = 300 #Strength to push player away when collided with enemy.

export var DEATH_SHAKE_STRENGTH = 3
#Range checking mode. Used when calling method within_player_range()
export (preset_range_checking_mode) var RANGE_CHECKING_MODE

export var ACTIVE_ON_SCREEN = Vector2(32, 32) #Active/inactive when the enemy is visible on screen by pixels offset

export var DESTROY_OUTSIDE_SCREEN : bool = true

export var PERMA_DEATH_SCENE = true #Die permanently WITHIN SCENE ONLY instead of respawning everytime enemy dies

export var PERMA_DEATH_LEVEL = false #Die permanently within current level. Useful with bosses and mini-bosses

export var IS_A_CLONE = false

export var invincible_enabled = false

export var show_invincible_sprite = false # Used for bosses

export var pickups_drop_enabled = true


export (PackedScene) var pickup_obj_weapon_large : PackedScene

export (PackedScene) var pickup_obj_weapon_small : PackedScene

export (PackedScene) var pickup_obj_life_large : PackedScene

export (PackedScene) var pickup_obj_life_small : PackedScene

export (PackedScene) var pickup_obj_life : PackedScene

#Child nodes:
onready var flicker_anim = $SpriteMain/FlickerAnimationPlayer
onready var sprite_main = $SpriteMain
onready var sprite = $SpriteMain/Sprite
onready var platform_collision_shape = $PlatformCollisionShape2D as CollisionShape2D
onready var level_camera = get_node("/root/Level/Camera2D")
onready var pickups_drop_set = $PickupsDropSet as ItemSet
onready var damage_sprite_ani = $DamageSprite/Ani
onready var invis_timer = $InvisTimer
onready var item_table = $ItemTable

onready var player = $"/root/Level/Iterable/Player"

onready var global_var = $"/root/GlobalVariables"
onready var fade_screen = $"/root/Level/FadeScreen"
onready var level := get_node_or_null("/root/Level") as Level
onready var player_stats = get_node("/root/PlayerStats")

#Temp variables
var current_hp
var initialy_inactive = false
var is_fresh_respawn = false
var is_reset_state_called = false #Call once
var is_coin_dropped = false
var is_invincible = false
var event_damage : float

#Preloaded scenes
var dmg_counter = preload("res://Src/Node/GUI/DamageCounter.tscn")
var explosion_particles = preload("res://Src/Node/GameObj/Effects/Particles/ExplosionParticles.tscn")

func _ready():
	if is_perma_dead():
		queue_free()
	
	if Difficulty.difficulty == Difficulty.DIFF_NEWCOMER:
		contact_damage *= 0.4
	if Difficulty.difficulty == Difficulty.DIFF_CASUAL:
		contact_damage *= 0.7
	if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
		contact_damage *= 2
	
	init_temp_variables()

func init_temp_variables():
	current_hp = hit_points_base

func _process(delta):
	_check_for_area_collisions()

func _physics_process(delta: float) -> void:
	#Check for my collision that overlapping areas
	_check_for_area_collisions()

func hit_by_player_projectile(var damage : float, var player_proj_source : PlayerProjectile) -> bool:
	var condition : bool #Init a return value
	
	#Check whether damage can be taken.
	var can_apply_damage : bool = true
	if not can_hit:
		can_apply_damage = false
	
	#Start apply damage if all conditions are met.
	if can_apply_damage:
		var damage_output = calculate_damage_output(damage)
		
		if not is_invincible:
			event_damage = damage_output
			emit_signal("taking_damage", damage_output, self, player_proj_source)
			damage_output = event_damage
			apply_damage(damage_output)
			emit_signal("taken_damage", damage_output, self, player_proj_source)
			if player_proj_source != null and (invincible_enabled or player_proj_source.invis_time_apply > 0):
				flicker_anim.play("Damage_Loop")
				
				if show_invincible_sprite:
					damage_sprite_ani.play("Flashing")
				
				if player_proj_source.invis_time_apply > 0:
					var _prev_invis_timer = invis_timer.wait_time
					invis_timer.start(player_proj_source.invis_time_apply)
					invis_timer.wait_time = _prev_invis_timer
				else:
					invis_timer.start()
				
				is_invincible = true
			else:
				#Play animation "Blink". Blinking sprite indicates that
				#the enemy is taking damage or being invincible.
				flicker_anim.play("Damage")
			
			check_for_death()
			spawn_damage_counter(damage_output)
		
		#Damage is applied. Set value to true.
		condition = true
	else:
		condition = false
	
	return condition

func _check_for_area_collisions():
	for i in damage_area_nodes:
		var node = get_node(i)
		if node == null:
			return
		
		var areas = node.get_overlapping_areas()
		
		for j in areas:
			#When player collides with enemy,
			#The character will take damage and will become invincible
			#for a short amount of time.
			#When invincible time is out, the player will be able to
			#take damage again.
			var player = j.get_owner()
			if player != null && player is Player:
				if can_damage:
					#Define call method
					var call_method = "player_take_damage"
					
					#Get necessary information of enemy.
					var enemy_parameters = [
						contact_damage,
						repel_player_enabled,
						get_global_position(),
						repel_power,
						damage_custom_invis_enabled,
						damage_custom_invis_timer
					]
					
					if player.has_method(call_method):
						player.callv(call_method, enemy_parameters)
			
			#If the bullet is detected
			var projectile = j
			if projectile != null && projectile is PlayerProjectile:
				#Check if bullet is capable of being destroyed at the end
				#Bullet may not get destroyed if enemy is being invincible.
				var destroy_bullet_at_the_end = get_node("/root/BitFlagsComparator").is_bit_enabled(projectile.DESTROY_ON_COLLIDE_TYPE, 0) && eat_player_projectile
				var can_bullet_hit = true #Init
				
				#Check if bullet is unable to hit (ignore)
				if (projectile.HIT_ONCE_PER_FRAME and projectile.is_hitted) or (!self.can_be_damaged()):
					can_bullet_hit = false
				elif projectile.is_reflected:
					can_bullet_hit = false
				elif get_node(i).has_node("ProjectileReflector"):
					var proj_reflector = get_node(i).get_node("ProjectileReflector") as ProjectileReflector
					var reflected = proj_reflector.do_reflect(projectile.projectile_name)
					
					#Start telling player's projectile that its bullet has been reflected.
					if reflected:
						projectile.reflected()
						can_bullet_hit = false
						destroy_bullet_at_the_end = false
				
				if can_bullet_hit:
					if projectile.apply_damage:
						hit_by_player_projectile(projectile.DAMAGE_POWER, projectile)
					projectile.emit_signal("hit_enemy", projectile)
					projectile.is_hitted = true
				
				#Destroy on overkill check.
				if current_hp <= 0 and not projectile.destroy_on_overkill:
					destroy_bullet_at_the_end = false
					projectile.is_hitted = false
				
				#Destroy projectile if hit an enemy.
				if destroy_bullet_at_the_end:
					projectile.queue_free_start()

#Calculates damage, return the damage output value.
func calculate_damage_output(var raw_damage : float) -> float:
	var damage_result = 0
	
	damage_result += raw_damage

	#Damage can't go below minimum.
	#Ex: If damage is -25, it's finalized as 1 by default.
	if damage_result < damage_taken_minimum:
		damage_result = damage_taken_minimum
	
	return damage_result

#Use calculated damage value to apply damage to enemy.
#Ignores invisibility time.
func apply_damage(var calculated_damage, var update_hp_bar = true):
	#Subtracting HP.
	current_hp -= calculated_damage

func can_be_damaged() -> bool:
	if (current_hp <= 0 and !death_immunity) or !eat_player_projectile:
		return false
	
	return true

#Check if hit points exceeds limit, normalize it.
#Optional to cut decimal hp value.
func normalize_hp(cut_float_value : bool = false) -> void:
	if current_hp > hit_points_base: #Normalize hp
		current_hp = hit_points_base
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
	if FJ_AudioManager.sfx_combat_buster.is_playing():
		FJ_AudioManager.sfx_combat_buster.call_deferred("stop")
	if FJ_AudioManager.sfx_combat_buster_minicharged.is_playing():
		FJ_AudioManager.sfx_combat_buster_minicharged.call_deferred("stop")
	if FJ_AudioManager.sfx_combat_buster_fullycharged.is_playing():
		FJ_AudioManager.sfx_combat_buster_fullycharged.call_deferred("stop")
	
	if !death_immunity && current_hp <= 0:
		play_death_sfx()
		emit_signal("dying")
		die()
	else:
		FJ_AudioManager.sfx_character_enemy_damage.play()
	

func die():
	#Create death animation effect
	if explosion_effect != null:
		var effect = explosion_effect.instance()
		get_parent().add_child(effect)
		effect.global_position = self.global_position
	
	#Drop coin when dies
	drop_item_start()
	drop_pickups_start()
	
	#Shake Camera
#	if level_camera != null:
#		level_camera.shake_camera(0.3, 50, DEATH_SHAKE_STRENGTH)
	
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

#Play death sound defined in export variable.
func play_death_sfx():
	match death_sound:
		dead_sfx.COLLAPSE:
			FJ_AudioManager.sfx_character_enemy_collapse.play()
		dead_sfx.LARGE_EXPLOSION:
			FJ_AudioManager.sfx_combat_large_explosion.play()
		dead_sfx.LARGE_EXPLOSION_MM3:
			FJ_AudioManager.sfx_combat_large_explosion_mm3.play()
		_:
			FJ_AudioManager.sfx_character_enemy_damage.stop()
	
	FJ_AudioManager.sfx_character_enemy_damage.stop()
	FJ_AudioManager.sfx_combat_buster.stop()
	FJ_AudioManager.sfx_combat_ring_boomerang.stop()
	FJ_AudioManager.sfx_combat_fall.stop()
	

func spawn_damage_counter(damage, offset : Vector2 = Vector2(0, 0)):
	if !GameSettings.gameplay.damage_popup_enemy:
		return
	
	var dmg_text = dmg_counter.instance() #Instance DamageCounter
	get_parent().add_child(dmg_text) #Spawn
	dmg_text.global_position = self.global_position #Set position to enemy
	dmg_text.position += offset #Offset
	dmg_text.label.text = str(damage)
	
	emit_signal("damage_counter_released", damage, self)

func drop_item_start():
	var drop_items : Array = item_table.get_items()
	
	#Iterate through available item pool.
	for i in drop_items:
		if i is ItemSetData:
			call_deferred("spawn_items_by_amount", i.item, i.quantity)

func drop_pickups_start():
	if not pickups_drop_enabled:
		return
	if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
		return
	
	var pickup = pickups_drop_set.get_an_item()
	if pickup is ItemSetData:
		spawn_pickup_by_name(pickup.item)


func spawn_pickup_by_name(pickup_name : String):
	var pickup_object
	
	match pickup_name:
		PICKUP_NONE:
			return
		PICKUP_WEAPON_ENERGY_SMALL:
			pickup_object = pickup_obj_weapon_small.instance()
			get_parent().add_child(pickup_object)
			pickup_object.global_position = global_position
		PICKUP_LIFE_ENERGY_SMALL:
			pickup_object = pickup_obj_life_small.instance()
			get_parent().add_child(pickup_object)
			pickup_object.global_position = global_position
		PICKUP_WEAPON_ENERGY_LARGE:
			pickup_object = pickup_obj_weapon_large.instance()
			get_parent().add_child(pickup_object)
			pickup_object.global_position = global_position
		PICKUP_LIFE_ENERGY_LARGE:
			pickup_object = pickup_obj_life_large.instance()
			get_parent().add_child(pickup_object)
			pickup_object.global_position = global_position
		PICKUP_LIFE:
			pickup_object = pickup_obj_life.instance()
			get_parent().add_child(pickup_object)
			pickup_object.global_position = global_position

func is_at_full_health():
	return current_hp >= hit_points_base

#When enemy leaves the screen, the enemy disappear.
func _on_PreciseVisibilityNotifier2D_visibility_exited():
	if DESTROY_OUTSIDE_SCREEN:
		#Reset to initial state for respawning
		queue_free_start(false)


func is_perma_dead() -> bool:
	return false

#Turn towards player. Flips SpriteMain so it'll
#have its scale.x fliped to either value of 1 or -1
func turn_toward_player():
	if player != null:
		var actual_player = player as Player
		if self.global_position.x > actual_player.global_position.x:
			sprite_main.scale.x = 1
		else:
			sprite_main.scale.x = -1

#Check whether player is within enemy's radius.
#Distance value is calculated by pixels.
#Range check mode, please see: const RANGE_CHECK_*.
func within_player_range(var rang : float) -> bool:
	if player != null:
		var actual_player = player as Player
		
		if get_player_distance() < rang:
			return true
	
	return false

#Get distance between player by pixels.
func get_player_distance() -> float:
	assert(player != null)
	var actual_player = player as Player
	
	match RANGE_CHECKING_MODE:
		preset_range_checking_mode.Radius:
			return self.global_position.distance_to(actual_player.global_position)
		preset_range_checking_mode.Horizontal:
			return self.global_position.x - actual_player.global_position.x
		preset_range_checking_mode.Vertical:
			return self.global_position.y - actual_player.global_position.y
	
	return 0.0

func get_sprite_main_direction() -> float:
	return sprite_main.scale.x

func _on_InvisTimer_timeout() -> void:
	is_invincible = false
	damage_sprite_ani.play("StopFlashing")
	flicker_anim.play("NoLongerDamage")

