extends EnemyCore

const VEL_Y_ON_WALL = 25

export (bool) var initial_state = true
export (float) var bouncing_power = 0.5

onready var pf_bhv := $PlatformBehavior as FJ_PlatformBehavior2D
onready var projectile_reflector = $DamageArea2D/ProjectileReflector

var move_direction #Will be used when the wheel cutter is landed for the 1st time.

func _ready():
	pf_bhv.INITIAL_STATE = initial_state
	projectile_reflector.enabled = !initial_state

func _process(delta):
	if is_on_wall():
		pf_bhv.velocity.y -= VEL_Y_ON_WALL * 60 * delta

func set_move_direction(dir : int):
	move_direction = dir

func _on_InitialStateStartTimer_timeout():
	pf_bhv.INITIAL_STATE = true
	projectile_reflector.enabled = false

func _on_PlatformBehavior_by_wall():
	FJ_AudioManager.sfx_combat_wheel_cutter_wall.play()
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
