#MetallK1000

extends EnemyCore

const MOVE_SPEED = 60
const ATTTACK_MOVE_SPEED = 0
const DASH_SPEED = 240

const ATTACK_RANGE = 76

export (float) var metall_spawned_walk_spd = 0

onready var pf_bhv = $PlatformBehavior
onready var sprite_ani = $SpriteMain/Sprite/Ani
onready var spawn_metall_pos = $SpriteMain/SpawnMetallPos

#temp
var state : int = 0

#Preload
var large_explosion_enemy = preload("res://Entities/Enemy/Obj/LargeExplosionEnemy.tscn")
var metall = preload("res://Entities/Enemy/Obj/Metall.tscn")

func _ready() -> void:
	pf_bhv.WALK_SPEED = MOVE_SPEED
	turn_toward_player()

func _process(delta: float) -> void:
	if state == 0 and within_player_range(ATTACK_RANGE):
		start_attack()

func _physics_process(delta: float) -> void:
	if not pf_bhv.on_floor and not state != 0:
		pf_bhv.simulate_walk_left = false
		pf_bhv.simulate_walk_right = false
	else:
		pf_bhv.simulate_walk_left = sprite_main.scale.x == 1
		pf_bhv.simulate_walk_right = !sprite_main.scale.x == 1

#Start attack
func start_attack():
	turn_toward_player()
	sprite_ani.play("Attacking")
	pf_bhv.WALK_SPEED = ATTTACK_MOVE_SPEED
	set_state(1)
	

#Metall jumps off, causing the train to dash at high speed.
func eject_dash():
	sprite_ani.play("Dashing")
	pf_bhv.WALK_SPEED = DASH_SPEED
	set_state(2)
	spawn_jumping_metall()

func spawn_jumping_metall():
	var enemy = metall.instance()
	get_parent().add_child(enemy)
	enemy.set_global_position(spawn_metall_pos.global_position)
	enemy.sprite_ani.play("Jumping")
	enemy.set_attacking_state(true)
	enemy.pf_bhv.jump_start(false)
	enemy.pf_bhv.simulate_walk_left = sprite_main.scale.x == -1
	enemy.pf_bhv.simulate_walk_right = sprite_main.scale.x == 1
	enemy.pf_bhv.WALK_SPEED = metall_spawned_walk_spd
	enemy.sprite_main.scale.x = self.sprite_main.scale.x
	enemy.set_reflect_enabled(false)

#Change side if by wall
#or Crash if it's dashing.
func _on_PlatformerBehavior_by_wall() -> void:
	sprite_main.scale.x *= -1
	if state == 2:
		var enemy = large_explosion_enemy.instance()
		get_parent().add_child(enemy)
		enemy.global_position = self.global_position
		enemy.database.general.combat.contact_damage = self.database.general.combat.contact_damage
		FJ_AudioManager.sfx_combat_large_explosion.play()
		queue_free()

func set_state(new_state : int):
	state = new_state

func turn_toward_player():
	if player != null:
		var actual_player = player as Player
		if self.global_position.x > actual_player.global_position.x:
			sprite_main.scale.x = 1
		else:
			sprite_main.scale.x = -1
		