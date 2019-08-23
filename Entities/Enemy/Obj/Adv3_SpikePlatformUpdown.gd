extends EnemyCore

export (float) var Y_POS
export (float) var detect_range = 32

var initial_pos : Vector2
var current_state = -1 #If it's 1, it's stated as "Raise". -1 otherwise.

onready var y_position_ani = $YPositionAni

func _ready():
	initial_pos = self.get_global_position()

func _physics_process(delta):
	_check_within_player_range()
	
	sprite_main.global_position.y = (initial_pos.y + Y_POS)

func _check_within_player_range():
	if within_player_range(detect_range):
		if !current_state == 1:
			y_position_ani.play("Raise")
			current_state = 1
	else:
		if !current_state == -1:
			y_position_ani.play_backwards("Raise")
			current_state = -1