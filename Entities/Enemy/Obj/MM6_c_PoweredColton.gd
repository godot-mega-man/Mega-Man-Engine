extends EnemyCore

export (float) var attack_range = 16

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
	_attack_process()

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
