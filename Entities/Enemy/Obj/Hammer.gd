#Slowly falls when player approraches close and
#slowly rises up while not.

extends EnemyCore

const INITIAL_LINE_HANG_POS := Vector2(0, -24)

export var approrach_range = 48
export var fall_speed := Vector2(0, 360)
export var rise_speed := Vector2(0, -360)

onready var sprite_ani = $SpriteMain/Sprite/AnimationPlayer
onready var pf_bhv = $PlatformBehavior
onready var hang_position = $SpriteMain/HangPosition

var initial_position : Vector2

func _ready() -> void:
	#Mark initial position for drawing line.
	initial_position = get_global_position()

func _process(delta: float) -> void:
	if within_player_range(approrach_range):
		sprite_ani.play("Falling")
		pf_bhv.GRAVITY_VEC = fall_speed
	else:
		sprite_ani.play("Idle")
		pf_bhv.GRAVITY_VEC = rise_speed
	