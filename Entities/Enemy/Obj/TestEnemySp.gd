extends EnemyCore

onready var iterable = $"/root/Level/Iterable"

export(float, 0.01, 30.0) var SHOOT_INTERVAL = 2.0
export(bool) var SHOOT_COUNTER_CLOCKWISE = false
export(float) var SHOOT_INCREASING_DEGREE = 10

#Temp variables
var current_bullet_deploy_time = 0

#Preloading Objects
var test_bullet = preload("res://Entities/Enemy/Obj/TestBullet.tscn")

#temp
onready var player = get_node_or_null("/root/Level/Iterable/Player")
var player_within_area : bool = false
var shot_dir = 0

func _process(delta: float) -> void:
	#If player is null, do nothing.
	if player == null:
		return
	
	#Increase time in delta
	current_bullet_deploy_time += delta
	
	#Shoot bullet
	if current_bullet_deploy_time > SHOOT_INTERVAL:
		current_bullet_deploy_time = 0
		
		if player.global_position.distance_to(self.global_position) < 100:
			#Shoots in 4 directions
			for i in 4:
				var bullet = test_bullet.instance()
				iterable.add_child(bullet)
				bullet.global_position = self.global_position
				bullet.bullet_behavior.angle_in_degrees = shot_dir + (i * 90)
				bullet.STRENGTH = 4
			
			shot_dir -= SHOOT_INCREASING_DEGREE if SHOOT_COUNTER_CLOCKWISE else -SHOOT_INCREASING_DEGREE
