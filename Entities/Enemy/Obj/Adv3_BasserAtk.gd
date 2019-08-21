extends EnemyCore

const DIRECTION_LEFT = -1
const DIRECTION_RIGHT = 1

enum State {
	IDLE,
	LEAP,
	FLYFORWARD
}

export (float) var attack_range = 180
export (float) var approrach_range = 32

onready var bullet_bhv = $BulletBehavior
onready var sine_bhv = $SineBehavior

var current_state = State.IDLE
var current_dir = 0

func _ready():
	if player != null:
		if player.global_position.x > global_position.x:
			current_dir = DIRECTION_RIGHT
		else:
			current_dir = DIRECTION_LEFT

func _process(delta):
	if current_state == State.IDLE:
		if player != null:
			if within_player_range(attack_range):
				#Set attack direction according to player current position
				if player.global_position.x > global_position.x:
					bullet_bhv.angle_in_degrees = 40
				else:
					bullet_bhv.angle_in_degrees = 130
			current_state = State.Leap
	if current_state == State.LEAP:
		pass
	if current_state == State.FLYFORWARD:
		pass
