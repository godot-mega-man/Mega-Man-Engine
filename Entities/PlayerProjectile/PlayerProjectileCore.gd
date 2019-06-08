extends Area2D
class_name PlayerProjectile

signal hit_tile(body)
signal hit_enemy(enemy_obj)
signal life_timeout

enum REFLECT_TYPE_PRESET {
	CANNOT_BE_STOPPED,
	CAN_BRE_REFLECTED,
	IS_DESTROYED
}

export(int) var DAMAGE_POWER = 16
export(bool) var apply_damage = true
export(float, 0, 1, 0.01) var DAMAGE_VARIANCE = 0.2
export(int, FLAGS, "DISTANCE", "TIME") var PROJECTILE_LIFETIME_TYPE = 1
export(float) var BULLET_MAX_TRAVEL_DISTANCE = 150
export(float, 0.01, 1000) var BULLET_LIFE_TIME = 1.0
export(int, FLAGS, "ENEMY", "TILE") var DESTROY_ON_COLLIDE_TYPE = 3

export(bool) var DESTROY_OUTSIDE_SCREEN = true
export(bool) var HIT_ONCE_PER_FRAME = true #If true, bullet can hit multiple enemies at the same time.

export(REFLECT_TYPE_PRESET) var reflect_type = 0

#Child nodes
onready var sprite = $Sprite
onready var visible_notify = $VisibilityNotifier2D
onready var bullet_behavior = $BulletBehavior
onready var reflect_animation = $ReflectAnimation
onready var reflected_destroy_timer = $ReflectedDestroyTimer

#Temp variables
var current_travel_distance = 0
var is_hitted = false
var life_time : float = 0
var is_reflected : bool = false #If true, it will become unusable.

func _ready():
	connect('body_entered', self, '_on_body_entered') #Used for collision with tiles or vice versa
	connect('area_entered', self, '_on_body_entered') #Used for collision with Area2D
	
	#Used for exiting screen check
	if DESTROY_OUTSIDE_SCREEN:
		visible_notify.connect('screen_exited', self, '_on_leaving_screen')

func _process(delta):
	#Bullet hit once per frame. Reset every frame.
	is_hitted = false

func _on_body_entered(body) -> void: #On bullet collides with anything
	#If the bullet detects that it collides with Tilemap
	if body is TileMap:
		#We destroy the player bullet if allowed.
		var bit_flag_comparator = BitFlagsComparator.new()
		if bit_flag_comparator.is_bit_enabled(DESTROY_ON_COLLIDE_TYPE, 1):
			emit_signal("hit_tile", body)
			queue_free_start()

func reflected():
	if is_reflected:
		return
	
	DESTROY_ON_COLLIDE_TYPE = 0
	bullet_behavior.active = true
	bullet_behavior.angle_in_degrees = rand_range(230, 310)
	bullet_behavior.speed = 60
	bullet_behavior.acceleration = 0
	bullet_behavior.gravity = 400
	bullet_behavior.allow_negative_speed = true
	bullet_behavior.current_acceleration = 0.0
	bullet_behavior.current_distance_traveled = 0.0
	bullet_behavior.current_gravity = 0.0
	
	get_node("/root/AudioManager").sfx_reflect.play()
	reflect_animation.play("Reflected")
	reflected_destroy_timer.start()
	
	is_reflected = true

#Can override this method.
func queue_free_start(var play_destroy_effect : bool = true):
	queue_free()

func _on_leaving_screen():
	if DESTROY_OUTSIDE_SCREEN:
		queue_free_start(false)