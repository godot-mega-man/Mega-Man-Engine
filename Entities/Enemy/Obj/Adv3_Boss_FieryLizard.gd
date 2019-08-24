extends BossCore

const CHANGE_COLOR_AT_HP = 12

export (int) var current_sprite_color_state #For animation

onready var palette_sprite = $SpriteMain/Sprite/PaletteSprite
onready var sprite_ani = $SpriteMain/Ani
onready var sprite_frame_ani = $SpriteMain/Sprite/SpriteFrameAni
onready var mouth_pos = $SpriteMain/Mouth
onready var process_ani = $ProcessAnimationPlayer

var current_phase = 1

#Preload
const bullet = preload("res://Entities/Enemy/Obj/Adv3_Bullet.tscn")
const flameburst_fireball = preload("res://Entities/Enemy/Obj/MM6_FlameBurstFireball.tscn")
const large_fieryball = preload("res://Entities/Enemy/Obj/Adv3_LargeFieryBall.tscn")

func _ready():
	pass

func _process(delta: float) -> void:
	if current_phase == 1:
		palette_sprite.current_palette_state = current_sprite_color_state
	if current_phase == 2:
		palette_sprite.current_palette_state = current_sprite_color_state + 4

func _on_FieryLizard_boss_done_posing() -> void:
	sprite_frame_ani.play("Animating")
	process_ani.play("EmergeAtkLargeFireball")
	

func _on_FieryLizard_taken_damage(value, target, player_proj_source) -> void:
	change_phase_check()

#Turns to blue color version.
func change_phase_check():
	if current_hp <= CHANGE_COLOR_AT_HP and current_phase == 1:
		current_phase = 2
		
		vital_bar_primary_color = NESColorPalette.NesColor.TORQUOISE3
		vital_bar_secondary_color = NESColorPalette.NesColor.TORQUOISE1
		update_current_boss_bar_colors()

func fire_bullet_at_player():
	var blt = bullet.instance()
	get_parent().add_child(blt)
	blt.global_position = mouth_pos.global_position
	var ag = mouth_pos.global_position.angle_to_point(player.global_position)
	blt.bullet_behavior.angle_in_degrees = rad2deg(ag) - 180
	
	FJ_AudioManager.sfx_combat_shot.play()

#Burst is a typo...
func fire_flame_blast():
	var blt = flameburst_fireball.instance()
	get_parent().add_child(blt)
	blt.global_position = mouth_pos.global_position
	if player != null:
		if player.global_position.x < global_position.x:
			blt.bullet_behavior.angle_in_degrees = rand_range(-255, -105)
		else:
			blt.bullet_behavior.angle_in_degrees = rand_range(-75, 75)
	
	FJ_AudioManager.sfx_combat_fireball.play()

func summon_large_fiery_balls():
	var fireball_count : int
	
	if current_phase == 1:
		fireball_count = 5
	else:
		fireball_count = 8
	
	for i in fireball_count:
		var fb = large_fieryball.instance()
		fb.global_position = global_position
		fb.offset = i * (2.0 / float(fireball_count))
		get_parent().add_child(fb)
	
	FJ_AudioManager.sfx_combat_fireball.play()