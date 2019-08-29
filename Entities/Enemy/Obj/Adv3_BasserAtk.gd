extends EnemyCore

const DIRECTION_LEFT = -1
const DIRECTION_RIGHT = 1

enum State {
	IDLE,
	LEAP,
	FLYFORWARD
}

export (float) var attack_range = 100
export (float) var approrach_range = 8

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
					bullet_bhv.angle_in_degrees = 60
					current_dir = 1
				else:
					bullet_bhv.angle_in_degrees = 130
					current_dir = -1
				bullet_bhv.active = true
				current_state = State.LEAP
	elif current_state == State.LEAP:
		if player != null:
			#Swap between horizontal and vertical mode
			#to check two range attacking mode one frame
			#and one frame the next.
			if RANGE_CHECKING_MODE == preset_range_checking_mode.Horizontal:
				RANGE_CHECKING_MODE = preset_range_checking_mode.Vertical
			elif RANGE_CHECKING_MODE == preset_range_checking_mode.Vertical:
				RANGE_CHECKING_MODE = preset_range_checking_mode.Horizontal
			if within_player_range(approrach_range):
				#Change state
				sine_bhv.active_on_start = true
				sine_bhv._init_position = get_position()
				if current_dir == 1:
					bullet_bhv.angle_in_degrees = 0
					bullet_bhv.speed = 45
				else:
					bullet_bhv.angle_in_degrees = 180
					bullet_bhv.speed = 45
				current_state = State.FLYFORWARD
		
		
	elif current_state == State.FLYFORWARD:
		pass
