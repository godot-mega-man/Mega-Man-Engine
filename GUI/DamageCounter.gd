extends Node2D

const LIMIT_TOP_OFFSET = 8

var GRAVITY = 450
var RANDOM_X_SWAY = 50
var RANDOM_Y_GEYSER_MIN = 150
var RANDOM_Y_GEYSER_MAX = 200

var stay_time = 0.8
var x_pos_sway = 0
var y_geyser = 0

#Child nodes
onready var label = $Label
onready var delete_timer = $DeleteTimer
onready var level = $"/root/Level"

func _ready():
	randomize()
	delete_timer.connect('timeout', self, '_on_delete_timer_timeout')
	start_delete_timer()
	x_pos_sway = rand_range(-RANDOM_X_SWAY, RANDOM_X_SWAY)
	y_geyser = rand_range(RANDOM_Y_GEYSER_MIN, RANDOM_Y_GEYSER_MAX)

func _process(delta):
	global_position.x += x_pos_sway * delta
	global_position.y -= y_geyser * delta
	y_geyser -= GRAVITY * delta
	
	#Limits how high this text can float.
#	var height_limit = level.CAMERA_LIMIT_TOP + LIMIT_TOP_OFFSET
#	if self.global_position.y < height_limit:
#		self.global_position.y = height_limit

func set_float_as_text(var number : float = 0):
	if GameSettings.gameplay.simplified_damage_number:
		label.text = NumberSimplifier.get_simplified_number(number)
	else:
		label.text = str(number)

func _on_delete_timer_timeout():
	queue_free()

func start_delete_timer():
	delete_timer.start(stay_time)