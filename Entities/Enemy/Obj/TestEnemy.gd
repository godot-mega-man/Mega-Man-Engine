extends EnemyCore

onready var iterable = $"/root/Level/Iterable"

export(float, 0.01, 30.0) var SHOOT_INTERVAL = 2.0

#Temp variables
var current_bullet_deploy_time = 0

#Preloading Objects
var test_bullet = preload("res://Entities/Enemy/Obj/TestBullet.tscn")

#temp
onready var player = get_node_or_null("/root/Level/Iterable/Player")
var player_within_area : bool = false

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
			var bullet = test_bullet.instance()
			iterable.add_child(bullet)
			bullet.global_position = self.global_position
			#Shoots toward player
			bullet.bullet_behavior.angle_in_degrees = rad2deg(self.global_position.angle_to_point(player.global_position)) + 180