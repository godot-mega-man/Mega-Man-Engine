extends EnemyCore

const BULLET = preload("res://Src/Node/GameObj/Enemy/Obj/MM2_Bullet.tscn")
const VEL_Y_ON_WALL = 25

export (bool) var initial_state = true
export (float) var bouncing_power = 0.5

onready var pf_bhv := $PlatformBehavior as FJ_PlatformBehavior2D
onready var projectile_reflector = $DamageArea2D/ProjectileReflector

var move_direction #Will be used when the wheel cutter is landed for the 1st time.

func _ready():
	if Difficulty.difficulty == Difficulty.DIFF_NEWCOMER:
		current_hp = 1
	if Difficulty.difficulty == Difficulty.DIFF_CASUAL:
		current_hp = 3
	
	pf_bhv.INITIAL_STATE = initial_state
	projectile_reflector.enabled = !initial_state

func _process(delta):
	if is_on_wall():
		pf_bhv.velocity.y -= VEL_Y_ON_WALL * 60 * delta
	
	_touhou_process()

func set_move_direction(dir : int):
	move_direction = dir


func release():
	if Difficulty.difficulty < Difficulty.DIFF_SUPERHERO:
		projectile_reflector.enabled = false
	
	pf_bhv.INITIAL_STATE = true


func _on_PlatformBehavior_by_wall():
	Audio.play_sfx("wheel_cutter_wall")
	pf_bhv.velocity.y = 0

func _on_PlatformBehavior_landed():
	bounce()
	start_move()

func bounce():
	pf_bhv.velocity.y = -pf_bhv.get_velocity_before_move_and_slide().y * bouncing_power

func start_move():
	match move_direction:
		1:
			pf_bhv.simulate_walk_right = true
		-1:
			pf_bhv.simulate_walk_left = true

func _on_PlatformBehavior_hit_ceiling():
	pickups_drop_enabled = false
	die()

func _touhou_process():
	return
	
	# Particle bullet
	if randi() % 25 == 0:
		var blt = BULLET.instance()
		get_parent().add_child(blt)
		blt.global_position = self.global_position
		blt.bullet_behavior.angle_in_degrees = -90 + rand_range(-20, 20)
		blt.bullet_behavior.speed = 150
		blt.bullet_behavior.acceleration = -180
		blt.bullet_behavior.gravity = 600

func spread_bullets():
	var angles = 60
	var count = 6
	
	for c in count:
		var blt = BULLET.instance()
		get_parent().add_child(blt)
		blt.global_position = self.global_position
		blt.bullet_behavior.angle_in_degrees = c * angles
		blt.bullet_behavior.speed = 0
		blt.bullet_behavior.acceleration = 120


func _on_WheelCutter_taking_damage(value, target, player_proj_source) -> void:
	if player_proj_source.projectile_name == "ring":
		event_damage = 0.5


func _on_PlatformBehavior_crushed() -> void:
	pickups_drop_enabled = false
	die()
