extends EnemyCore

export (float) var attack_range = 16
export var CURRENT_PALETTE_STATE = 0 #Sets by palette anim player.
export (NESColorPalette.NesColor) var primary_color = NESColorPalette.NesColor.TOMATO2
export (NESColorPalette.NesColor) var secondary_color = NESColorPalette.NesColor.LIGHTSTEELBLUE3
export (NESColorPalette.NesColor) var outline_color = NESColorPalette.NesColor.BLACK1
export (NESColorPalette.NesColor) var outline_color_charge1 = NESColorPalette.NesColor.CHOCOLATE1
export (NESColorPalette.NesColor) var outline_color_charge2 = NESColorPalette.NesColor.CHOCOLATE2
export (NESColorPalette.NesColor) var outline_color_charge3 = NESColorPalette.NesColor.CHOCOLATE3

onready var palette_sprite = $SpriteMain/Sprite/PaletteSprite
onready var palette_ani = $SpriteMain/Sprite/PaletteAni
onready var palette_ani_changer = $SpriteMain/Sprite/PaletteAni/PaletteAniChanger
onready var charge_start_timer = $ChargeStartDelayTimer
onready var charge_timer = $ChargeTimer
onready var fire_position = $SpriteMain/FirePosition
onready var sprite_ani = $SpriteMain/Ani
onready var charge_sound = $ChargeSound

var is_attack_ready = true #Preemptive attack
var blues_charged_shot_bullet = preload("res://Entities/Enemy/Obj/MM10_BluesChargedShot.tscn")

func _ready():
	turn_toward_player()

#Turns toward player every intervals
func _on_TurnTowardsTimer_timeout() -> void:
	turn_toward_player()

func _process(delta: float) -> void:
	_update_palettes()
	_attack_process()

func _update_palettes():
	match CURRENT_PALETTE_STATE:
			0:
				palette_sprite.primary_sprite.modulate = Color(primary_color)
				palette_sprite.second_sprite.modulate = Color(secondary_color)
				palette_sprite.outline_sprite.modulate = Color(outline_color)
			1:
				palette_sprite.primary_sprite.modulate = Color(primary_color)
				palette_sprite.second_sprite.modulate = Color(secondary_color)
				palette_sprite.outline_sprite.modulate = Color(outline_color_charge1)
			2:
				palette_sprite.primary_sprite.modulate = Color(primary_color)
				palette_sprite.second_sprite.modulate = Color(secondary_color)
				palette_sprite.outline_sprite.modulate = Color(outline_color_charge2)
			3:
				palette_sprite.primary_sprite.modulate = Color(primary_color)
				palette_sprite.second_sprite.modulate = Color(secondary_color)
				palette_sprite.outline_sprite.modulate = Color(outline_color_charge3)
			4:
				palette_sprite.primary_sprite.modulate = Color(secondary_color)
				palette_sprite.second_sprite.modulate = Color(outline_color)
				palette_sprite.outline_sprite.modulate = Color(primary_color)
			5:
				palette_sprite.primary_sprite.modulate = Color(outline_color)
				palette_sprite.second_sprite.modulate = Color(primary_color)
				palette_sprite.outline_sprite.modulate = Color(secondary_color)


func _attack_process():
	if is_attack_ready:
		if within_player_range(attack_range):
			fire()

func fire():
	var bullet = blues_charged_shot_bullet.instance()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	if player != null:
		if player.global_position.x < fire_position.global_position.x:
			bullet.bullet_behavior.angle_in_degrees = 180
			bullet.sprite_main.scale.x = -1
		
		bullet.get_node("SpriteMain/Sprite/PaletteSprite/Primary").modulate = Color(primary_color)
		bullet.get_node("SpriteMain/Sprite/PaletteSprite/Secondary").modulate = Color(secondary_color)
		bullet.get_node("SpriteMain/Sprite/PaletteSprite/Outline").modulate = Color(outline_color)
	
	FJ_AudioManager.sfx_combat_blues_shot.play()
	charge_sound.stop()
	
	is_attack_ready = false
	palette_ani_changer.play("NoCharge")
	charge_start_timer.start()
	sprite_ani.play("Attack")


func _on_ChargeStartDelayTimer_timeout() -> void:
	charge_timer.start()
	palette_ani_changer.play("Charging")
	charge_sound.play()


func _on_ChargeTimer_timeout() -> void:
	is_attack_ready = true
	palette_ani_changer.play("FullyCharged")
