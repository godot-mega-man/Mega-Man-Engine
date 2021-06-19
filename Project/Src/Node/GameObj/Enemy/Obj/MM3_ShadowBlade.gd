extends EnemyProjectile

const LARGE_EXPLOSION = preload("res://Src/Node/GameObj/Enemy/Obj/MM3_LargeExplosion.tscn")

onready var dmg_area = $DamageArea2D

var explode_on_hit : bool
var exploded : bool

func _physics_process(delta: float) -> void:
	_collision_tile()

func _collision_tile():
	if not explode_on_hit:
		return
	if exploded:
		return
	
	var bodies = dmg_area.get_overlapping_bodies()
	
	if not bodies.empty():
		explode()
		exploded = true

func explode():
	var e = LARGE_EXPLOSION.instance()
	get_parent().add_child(e)
	e.global_position = global_position
	e.can_damage = false
	Audio.play_sfx("thunder")
	
	bullet_behavior.angle_in_degrees = -90 + rand_range(-15, 15)
	bullet_behavior.speed = 180
	bullet_behavior.gravity = 900


func _on_BulletBehavior_stopped_moving() -> void:
	var ag_tw_player = self.global_position.angle_to_point(player.global_position)
	bullet_behavior.angle_in_degrees = rad2deg(ag_tw_player) - 180
	bullet_behavior.acceleration = 800

