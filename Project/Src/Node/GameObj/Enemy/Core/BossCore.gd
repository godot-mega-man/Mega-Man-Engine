# BossCore

# NOTE: This was created but is unintended to make the boss to do everything
# in the way the code badly optimizes.
# NOTE2: This script has received feedbacks prior to the boss script by
# university students and will be refactored to make the code easier to read.
#
# TODO: Remove magic numbers
# TODO: Change the boss to not do every single things in one script


class_name BossCore extends EnemyCore


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

export (NESColorPalette.NesColor) var vital_bar_primary_color

export (NESColorPalette.NesColor) var vital_bar_secondary_color

export (NESColorPalette.NesColor) var vital_bar_outline_color


var thiuns = preload("res://Src/Node/GameObj/Effects/MM_Thiun/Thiun.tscn")

#Is posing : Posing boss is a state where the boss won't attack while this happens.
var is_posing = true


func _ready():
	update_current_boss_bar_colors()
	start_intro_music_or_regular_music()
	stop_player_controls()
	GameHUD.connect("boss_vital_bar_fully_filled", self, "_on_boss_vital_bar_fully_filled")
	Audio.stop_sfx("buster_charging")


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
	
	Audio.play_sfx("player_dead")


#Start intro music (if specified). Otherwise, boss music will be
#used instead.
func start_intro_music_or_regular_music():
	#If start music on spawn enabled, plays the intro music.
	if start_music_on_spawn:
		if intro_music == null:
			Audio.play_bgm(boss_music)
		else:
			Audio.play_bgm(intro_music)


#Stop player's control
func stop_player_controls():
	if stop_player_controls_on_spawn:
		if player != null:
			player.set_control_enable(false)


func start_show_boss_health_bar():
	GameHUD.update_boss_vital_bar(0)
	GameHUD.boss_vital_bar.set_visible(true)


func start_fill_up_health_bar():
	GameHUD.fill_boss_vital_bar(28)
	current_hp = 28


#Fill up bar to max... Start playing music.
func _on_boss_vital_bar_fully_filled():
	if boss_music != null:
		Audio.play_bgm(boss_music)
	if player != null:
		player.set_control_enable(true)
	emit_signal("boss_done_posing")
	is_posing = false


func update_current_boss_bar_colors():
	GameHUD.boss_vital_bar_palette.primary_sprite.modulate = vital_bar_primary_color
	GameHUD.boss_vital_bar_palette.second_sprite.modulate = vital_bar_secondary_color


func destroy_all_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	
	for enemy in enemies:
		if not enemy is EnemyCore:
			continue
		if enemy.is_in_group("Boss"):
			continue
		
		enemy.queue_free()


#When the boss takes damage, update boss health bar.
#Makes the boss invincible for a short time.
func _on_BossCore_taken_damage(value, target, player_proj_source) -> void:
	GameHUD.update_boss_vital_bar(ceil(current_hp))


#When dies, the level music starts or stops.
#Hides boss health bar GUI.
func _on_BossCore_slain(target) -> void:
	destroy_all_enemies()
	if stop_music_after_death:
		Audio.stop_bgm()
		level.begin_victory_process()
	else:
		if level != null:
			Audio.play_bgm(level.MUSIC)
	
	create_thuin()

