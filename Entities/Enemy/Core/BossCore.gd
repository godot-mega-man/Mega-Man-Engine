#BossCore
#Code by: First

# BossCore is mainly used as a placeholder for a boss battle.
# When it spawns, it will usually stop the player's control and
# won't be able to open up inventory menu or pause screen.
# The boss can poses before begin filling up health bar (slowly 
# or instantly depends on the design) and the fight begins as normal.

# Bosses normally dies just like a regular enemy, only the differences
# are the health bar may gets hidden and restoring background music's
# state. When this happens, all active enemies also dies in the process.
# By design, please note that you should not make any projectile
# spawned by boss drops anything (experience points are acceptable).

# Any bosses placed anywhere in the scene permanently dies by default.

# Steps to begin the fight:
#   1. Call method - start_show_boss_health_bar()
#   2. Then call another - start_fill_up_health_bar()
# These steps can be called through AnimationPlayer or manually
# through code. It's highly recommended to check out how the boss
# is created located in DEV_ExampleUsages folder:
#   res://DEV_ExampleUsages/Ex_LevelCreationTest/MegaMan_Level/EnemyObj/Boss_FreezeMan.tscn
# where the boss is used at:
#   res://DEV_ExampleUsages/Ex_LevelCreationTest/MegaMan_Level/Level_Sub2.tscn

extends EnemyCore

class_name BossCore

signal boss_done_posing

export (AudioStreamOGGVorbis) var intro_music
export (AudioStreamOGGVorbis) var boss_music
export (bool) var start_music_on_spawn = true #If no music specified, nothing happens
export (bool) var stop_player_controls_on_spawn = true
export (bool) var die_to_pits = true
export (bool) var show_boss_health_bar = true
export (float) var fill_up_health_bar_duration = 2.0
export (bool) var stop_music_after_death #If false, the game music will resume.
export (bool) var destroy_all_enemies_on_death = true

var thiuns = preload("res://DEV_ExampleUsages/Ex_LevelCreationTest/MegaMan_Level/MM_Thiun/Thiun.tscn")

func create_thuin() -> void:
	var speed = [60,120]
	var degrees_increment = 45
	var create_count = 8
	
	for i in speed:
		for j in create_count:
			var eff = thiuns.instance()
			get_parent().add_child(eff)
			eff.get_node("BulletBehavior").angle_in_degrees = degrees_increment * j
			eff.get_node("BulletBehavior").speed = i
			eff.global_position = self.global_position
	
	FJ_AudioManager.sfx_character_player_die.play()

#Is posing : Posing boss is a state where the boss won't attack while this happens.
var is_posing = true

func _ready():
	start_intro_music_or_regular_music()
	stop_player_controls()

#Start intro music (if specified). Otherwise, boss music will be
#used instead.
func start_intro_music_or_regular_music():
	#If start music on spawn enabled, plays the intro music.
	if start_music_on_spawn:
		if intro_music == null:
			FJ_AudioManager.play_bgm(boss_music)
		else:
			FJ_AudioManager.play_bgm(intro_music)

#Stop player's control
func stop_player_controls():
	if stop_player_controls_on_spawn:
		if player != null:
			player.set_control_enable(false)

func start_show_boss_health_bar():
	if level != null:
		if not show_boss_health_bar:
			return
		level.boss_health_bar.show_health_bar(database.general.stats.hit_points_base, database.general.stats.nickname)
		level.boss_health_bar.connect("filled_up_bar_to_max", self, "_on_boss_health_bar_filled_up_bar_to_max")
	else:
		push_warning(str(self.get_path, ": Health bar was not shown. Level not found."))

func start_fill_up_health_bar():
	if level != null:
		level.boss_health_bar.fill_up_hp(fill_up_health_bar_duration)
	else:
		push_warning(str(self.get_path, ": Health bar was not filled up. Level not found."))

#Fill up bar to max... Start playing music.
func _on_boss_health_bar_filled_up_bar_to_max():
	if boss_music != null:
		FJ_AudioManager.play_bgm(boss_music)
	if player != null:
		player.set_control_enable(true)
	emit_signal("boss_done_posing")
	is_posing = false

#When the boss takes damage, update boss health bar.
func _on_BossCore_taken_damage(value, target, player_proj_source) -> void:
	if level != null:
		if not show_boss_health_bar:
			return
		level.boss_health_bar.update_health_bar(self.current_hp)

#When dies, the level music starts or stops.
#Hides boss health bar GUI.
func _on_BossCore_slain(target) -> void:
	destroy_all_enemies()
	if stop_music_after_death:
		FJ_AudioManager.stop_bgm()
	else:
		if level != null:
			FJ_AudioManager.play_bgm(level.MUSIC)
	level.boss_health_bar.hide_health_bar()
	
	create_thuin()

#Use case: When the boss is slain.
func destroy_all_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for i in enemies:
		if i is EnemyCore:
			if not i.is_in_group("Boss"):
				i.die()