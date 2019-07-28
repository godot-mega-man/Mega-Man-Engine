extends EnemyCore

#Export vars
export(int, "Left", "Right") var facing = 0

#Child nodes
onready var pf_bhv = $PlatformBehavior
onready var shield_area = $SpriteMain/ShieldArea2D
onready var shield_col_area = $SpriteMain/ShieldArea2D/CollisionShape2D
onready var shield_ani = $SpriteMain/Sprite/ShieldAni

#Temp
var last_saved_move_speed : Vector2

func _ready() -> void:
	#Turns left or right at initial
	if facing == 1:
		flip_sprite()
		pf_bhv.GRAVITY_VEC *= -1

func flip_sprite() -> void:
	sprite_main.scale.x *= -1

func enable_shield_collision(var set : bool) -> void:
	shield_col_area.call_deferred("set_disabled", !set)

func start_moving() -> void:
	shield_ani.play("Moving")
	pf_bhv.GRAVITY_VEC = last_saved_move_speed * -1

func _on_PlatformerBehavior_move_and_collided(kinematic_collision) -> void:
	if shield_ani.current_animation == "Moving":
		last_saved_move_speed = pf_bhv.GRAVITY_VEC
		pf_bhv.GRAVITY_VEC = Vector2(0, 0)
		shield_ani.play("Turning")