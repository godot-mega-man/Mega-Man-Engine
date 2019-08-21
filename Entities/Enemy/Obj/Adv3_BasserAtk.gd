extends EnemyCore

const DIRECTION_LEFT = -1
const DIRECTION_RIGHT = 1

enum State {
	IDLE,
	LEAP,
	FLYFORWARD
}

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
#			if player.global_position.x 
			pass
	if current_state == State.LEAP:
		pass
	if current_state == State.FLYFORWARD:
		pass
