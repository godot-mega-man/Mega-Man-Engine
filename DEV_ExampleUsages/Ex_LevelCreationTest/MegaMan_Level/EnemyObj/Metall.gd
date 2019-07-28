#Metall (Various attack pattern)

extends EnemyCore

const ATTACK_RANGE = 96

enum ATTACK_MODE_PRESET {
	REGULAR,
	SPIN
}

export (ATTACK_MODE_PRESET) var attack_mode = 1

onready var pf_bhv := $PlatformBehavior
onready var sprite_ani = $SpriteMain/Sprite/Ani
onready var damage_area_reflector = $DamageArea/ProjectileReflector

#temp
var attack_ready = true
var state : int = 0

#preload
var generelea = preload("res://DEV_ExampleUsages/Ex_LevelCreationTest/MegaMan_Level/EnemyObj/Bullet.tscn")

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if state == 0:
		if attack_ready and within_player_range(ATTACK_RANGE):
			pop_out()

func pop_out():
	set_attacking_state(true)
	sprite_ani.play("PopOut")
	turn_toward_player()

#Called from sprite_ani after animation of PopOut is finished.
func attack():
	if attack_mode == ATTACK_MODE_PRESET.REGULAR:
		pass
	if attack_mode == ATTACK_MODE_PRESET.SPIN:
		sprite_ani.play("Spinning")

func set_attacking_state(var new_state : bool) -> void:
	if new_state == true:
		state = 1
	else:
		state = 0
	
	attack_ready = !new_state



func hide():
	sprite_ani.play("Hiding")
	pf_bhv.simulate_walk_left = false
	pf_bhv.simulate_walk_right = false

func hide_finish():
	set_attacking_state(false)
	sprite_ani.play("Idle")

func set_reflect_enabled(var set : bool):
	damage_area_reflector.enabled = set

func shoot_straight():
	var bullet = generelea.instance()
	get_parent().add_child(bullet)
	bullet.global_position = self.global_position
	bullet.bullet_behavior.speed = 120
	if sprite_main.scale.x == 1:
		bullet.bullet_behavior.angle_in_degrees += 180

#While attacking and when landed
func _on_PlatformerBehavior_landed() -> void:
	if state == 1:
		hide()
