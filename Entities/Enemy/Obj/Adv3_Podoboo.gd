extends EnemyCore

onready var pf_bhv = $PlatformBehavior

export (float) var jump_power = 400
export (float) var jump_power_variance = 1.3

func _ready():
	#Initialize jump power onto platform behavior.
	pf_bhv.JUMP_SPEED = jump_power * rand_range(1, jump_power_variance)
	
	#Mid-air jumps at the beginning.
	pf_bhv.jump_start(false)

func _process(delta):
	if pf_bhv.velocity.y > 0:
		sprite_main.scale.y = -1