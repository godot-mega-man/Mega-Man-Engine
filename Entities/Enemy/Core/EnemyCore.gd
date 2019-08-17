extends KinematicBody2D

class_name EnemyCore

signal taken_damage(value, target, player_proj_source)
signal dropped_coin(value, count)
signal dropped_item(item_data, quantity)
signal dropped_diamond
signal damage_counter_released(value, target)
signal slain(target)
signal despawned(by_dying)

enum preset_range_checking_mode {
	Radius, Horizontal, Vertical
}

#Dead sound effect
enum dead_sfx {
	COLLAPSE,
	LARGE_EXPLOSION
}

const PICKUP_NONE = ""
const PICKUP_WEAPON_ENERGY_SMALL = "WeaponEnergySmall"
const PICKUP_LIFE_ENERGY_SMALL = "LifeEnergySmall"
const PICKUP_WEAPON_ENERGY_LARGE = "WeaponEnergyLarge"
const PICKUP_LIFE_ENERGY_LARGE = "LifeEnergyLarge"
const PICKUP_LIFE = "Life"

export (PackedScene) var _database
export (Texture) var sprite_preview_texture
export (Array, NodePath) onready var damage_area_nodes
export var explosion_effect = preload('res://Entities/Effects/Explosion/Explosion.tscn')
export (dead_sfx) var death_sound = dead_sfx.COLLAPSE

export var DEATH_SHAKE_STRENGTH = 3
export var CAN_GAIN_WEAPON_EXP = true #Applying damage to enemy also increase player weapon's experience
export var GAIN_WEAPON_EXP_RATIO = 1.0 #Ratio of weapon's experience gains.

#Range checking mode. Used when calling method within_player_range()
export (preset_range_checking_mode) var RANGE_CHECKING_MODE

export var ACTIVE_ON_SCREEN = Vector2(32, 32) #Active/inactive when the enemy is visible on screen by pixels offset
export var PERMA_DEATH_SCENE = true #Die permanently WITHIN SCENE ONLY instead of respawning everytime enemy dies
export var PERMA_DEATH_LEVEL = false #Die permanently within current level. Useful with bosses and mini-bosses
export var IS_A_CLONE = false
export var invincible_enabled = false
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
onready var hp_bar = $HpBar
onready var active_vis_notifier = $ActiveVisNotifier
onready var level_camera = get_node("/root/Level/Camera2D")
onready var pickups_drop_set = $PickupsDropSet as ItemSet
onready var damage_sprite_ani = $DamageSprite/Ani
onready var invis_timer = $InvisTimer

onready var player = $"/root/Level/Iterable/Player"

onready var global_var = $"/root/GlobalVariables"
onready var fade_screen = $"/root/Level/FadeScreen"
onready var level := get_node_or_null("/root/Level") as Level
onready var player_stats = get_node("/root/PlayerStats")

onready var database : EnemyDatabase

#Temp variables
var current_hp
var initialy_inactive = false
var is_fresh_respawn = false
var is_reset_state_called = false #Call once
var is_coin_dropped = false
var path_to_spawned_dmg_counter_obj : NodePath #Temp reference obj
var is_invincible = false

#Preloaded scenes
var dmg_counter = preload("res://GUI/DamageCounter.tscn")
var coin = preload("res://Entities/Coin/Coin1.tscn")
var item = preload("res://Entities/Coin/Item.tscn")
var diamond = preload("res://Entities/Coin/Diamond1.tscn")
var explosion_particles = preload("res://Entities/Effects/Particles/ExplosionParticles.tscn")
var database_preload = preload("res://DatabaseCore/Enemy/Core/Database.tscn")

func _ready():
	init_database()
	
	#Wait... Am I permanently died?
	if is_perma_dead():
		queue_free()
	
	#Connect to GameSettings to set hp bar visible/invisible on updated.
	GameSettings.gameplay.connect("show_enemy_hp_bars_changed", self, "_on_setting_show_enemy_hp_bars_changed")
	_on_setting_show_enemy_hp_bars_changed(GameSettings.gameplay.show_enemy_hp_bars)
	
	init_temp_variables()
	hp_bar.init_health_bar(0, database.general.stats.hit_points_base, current_hp)

func init_database():
	if _database != null:
		database = _database.instance()
		add_child(database)
	else:
		database = database_preload.instance()
		add_child(database)

func init_temp_variables():
	current_hp = database.general.stats.hit_points_base

func _process(delta):
	_check_for_area_collisions()

func _physics_process(delta: float) -> void:
	#Check for my collision that overlapping areas
	_check_for_area_collisions()

func hit_by_player_projectile(var damage : float, var player_proj_source : PlayerProjectile) -> bool:
	var condition : bool #Init a return value
	
	#Check whether damage can be taken.
	var can_apply_damage : bool = true
	if not database.general.combat.can_hit:
		can_apply_damage = false
	
	#Start apply damage if all conditions are met.
	if can_apply_damage:
		var damage_output = calculate_damage_output(damage)
		
		if not is_invincible:
			apply_damage(damage_output)
			emit_signal("taken_damage", damage_output, self, player_proj_source)
			check_for_death()
			spawn_damage_counter(damage_output)
			if invincible_enabled:
				flicker_anim.play("Damage_Loop")
				damage_sprite_ani.play("Flashing")
				invis_timer.start()
				is_invincible = true
			else:
				#Play animation "Blink". Blinking sprite indicates that
				#the enemy is taking damage or being invincible.
				flicker_anim.play("Damage")
		
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
				if database.general.combat.can_damage:
					#Define call method
					var call_method = "player_take_damage"
					
					#Get necessary information of enemy.
					var enemy_parameters = [
						database.general.combat.contact_damage,
						database.general.stats.repel_player_enabled,
						get_global_position(),
						database.general.stats.repel_power,
						database.general.combat.damage_custom_invis_enabled,
						database.general.combat.damage_custom_invis_timer
					]
					
					if player.has_method(call_method):
						player.callv(call_method, enemy_parameters)
			
			#If the bullet is detected
			var projectile = j
			if projectile != null && projectile is PlayerProjectile:
				#Check if bullet is capable of being destroyed at the end
				#Bullet may not get destroyed if enemy is being invincible.
				var destroy_bullet_at_the_end = get_node("/root/BitFlagsComparator").is_bit_enabled(projectile.DESTROY_ON_COLLIDE_TYPE, 0) && database.general.combat.eat_player_projectile
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
	if damage_result < database.general.combat.damage_taken_minimum:
		damage_result = database._general.combat.damage_taken_minimum
	
	return damage_result

#Use calculated damage value to apply damage to enemy.
#Ignores invisibility time.
func apply_damage(var calculated_damage, var update_hp_bar = true):
	#Subtracting HP.
	current_hp -= calculated_damage
	
	#Update health bar
	if update_hp_bar:
		hp_bar.update_hp_bar(current_hp)

func can_be_damaged() -> bool:
	if (
		(current_hp <= 0 and !database.general.combat.death_immunity) or
		!database.general.combat.eat_player_projectile
	):
		return false
	
	return true

#Check if hit points exceeds limit, normalize it.
#Optional to cut decimal hp value.
func normalize_hp(cut_float_value : bool = false) -> void:
	if current_hp > database.general.stats.hit_points_base: #Normalize hp
		current_hp = database.general.stats.hit_points_base
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
	
	if !database.general.combat.death_immunity && current_hp <= 0:
		if FJ_AudioManager.sfx_character_enemy_damage.is_playing():
			FJ_AudioManager.sfx_character_enemy_damage.call_deferred("stop")
		play_death_sfx()
		die()
	else:
		FJ_AudioManager.sfx_character_enemy_damage.play()

func die():
	#Create death animation effect
	var effect = explosion_effect.instance()
	effect.position = self.global_position
	get_parent().add_child(effect)
	
	#Drop coin when dies
	drop_item_start()
	drop_pickups_start()
	
	#Shake Camera
	if level_camera != null:
		level_camera.shake_camera(0.3, 50, DEATH_SHAKE_STRENGTH)
	
	#Start queue freeing, tell the method that this obj is slain.
	call_deferred('queue_free_start', true)
	
	#Emit signal
	emit_signal("slain", self)

#Start queue freeing.
func queue_free_start(by_dying : bool):
	if !is_reset_state_called: #Called once
		is_reset_state_called = true
		
		#If dying, saves dying state to global variables.
		if by_dying:
			save_death_state()
		
		emit_signal("despawned", by_dying)
		
		queue_free()

#Play death sound defined in export variable.
func play_death_sfx():
	match death_sound:
		dead_sfx.COLLAPSE:
			FJ_AudioManager.sfx_character_enemy_collapse.play()
		dead_sfx.LARGE_EXPLOSION:
			FJ_AudioManager.sfx_combat_large_explosion.play()
	

func spawn_damage_counter(damage, offset : Vector2 = Vector2(0, 0)):
	if !GameSettings.gameplay.damage_popup_enemy:
		return
	
	if path_to_spawned_dmg_counter_obj.is_empty() or get_node_or_null(path_to_spawned_dmg_counter_obj) == null:
		var dmg_text = dmg_counter.instance() #Instance DamageCounter
		dmg_text.global_position = self.global_position #Set position to enemy
		dmg_text.position += offset #Offset
		dmg_text.current_damage_value += damage
		get_parent().add_child(dmg_text) #Spawn
		
		
		path_to_spawned_dmg_counter_obj = dmg_text.get_path()
	else:
		var obj_dmg_counter = get_node(path_to_spawned_dmg_counter_obj)
		if obj_dmg_counter is DamageCounter:
			obj_dmg_counter.current_damage_value += damage
			obj_dmg_counter.global_position = self.global_position #Set position to enemy
			obj_dmg_counter.restart()
	
	emit_signal("damage_counter_released", damage, self)

func drop_coin_start():
	#If this enemy do not drop coin upon death... Do nothing.
	if !database.loots.coin.drop_coin:
		return
	
	call_deferred("spawn_coins_by_amount", database.loots.coin.coin_value, database.loots.coin.spawn_count)

func drop_item_start():
	var drop_items : Array = database.loots.item_table.get_items()
	
	#Iterate through available item pool.
	for i in drop_items:
		if i is ItemSetData:
			call_deferred("spawn_items_by_amount", i.item, i.quantity)

func drop_diamond_start():
	#If this enemy do not drop diamond upon death... Do nothing.
	if !database.loots.diamond.drop_diamond:
		return
	
	var chance = rand_range(0, 1) #Chance to drop diamond
	#Check for drop chance
	if chance < database.loots.diamond.DIAMOND_DROP_CHANCE:
		call_deferred("spawn_a_diamond")

func drop_pickups_start():
	if not pickups_drop_enabled:
		return
	var pickup = pickups_drop_set.get_an_item()
	if pickup is ItemSetData:
		spawn_pickup_by_name(pickup.item)

func spawn_items_by_amount(var item_path : String, var quantity : int = 1):
	if item_path.empty():
		return
	
	for i in quantity:
		var item_inst = item.instance()
		get_parent().call_deferred("add_child", item_inst)
		item_inst.item_data_file = item_path #File
		item_inst.ITEM_TYPE = 1 #Item
		item_inst.global_position = self.global_position
	
	emit_signal("dropped_item", item_path, quantity)

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
	return current_hp >= database.general.stats.hit_points_base

#When enemy leaves the screen, the enemy disappear.
func _on_ActiveVisNotifier_screen_exited():
	#Reset to initial state for respawning
	queue_free_start(false)

func _on_setting_show_enemy_hp_bars_changed(enable):
	if hp_bar.affects_game_settings:
		hp_bar.visible = enable

func save_death_state():
	var dead_info = DeadEnemyInfo.new()
	dead_info.scene_file_name = get_tree().get_current_scene().filename
	dead_info.file_name = self.filename
	dead_info.global_pos = self.global_position
	
	global_var.add_to_dead_enemies(dead_info)

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
			return abs(self.global_position.x - actual_player.global_position.x)
		preset_range_checking_mode.Vertical:
			return abs(self.global_position.y - actual_player.global_position.y)
	
	assert(false) #Mode error!

func get_sprite_main_direction() -> float:
	return sprite_main.scale.x

func _on_InvisTimer_timeout() -> void:
	is_invincible = false
	damage_sprite_ani.play("StopFlashing")
	flicker_anim.play("NoLongerDamage")
