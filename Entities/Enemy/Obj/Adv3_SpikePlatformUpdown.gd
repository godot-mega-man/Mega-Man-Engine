extends EnemyCore

export (float) var Y_POS
export (float) var detect_range = 48

var initial_pos : Vector2
var current_state = false #If true, it's stated as "Raise"

onready var y_position_ani = $YPositionAni

func _ready():
	initial_pos = self.get_global_position()

func _physics_process(delta):
	if within_player_range(detect_range):
		if !current_state:
			y_position_ani.play("Raise")
			current_state = true
	else:
		if current_state:
			y_position_ani.play_backwards("Raise")
			current_state = false
	
	sprite_main.global_position.y = (initial_pos.y + Y_POS)