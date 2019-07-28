extends EnemyProjectile

export (PackedScene) var watton_bullet = preload("res://DEV_ExampleUsages/Ex_LevelCreationTest/MegaMan_Level/EnemyObj/100WattonBullet.tscn")
export(Array, float) var rndm_explode_time_pool = [0.8, 0.85, 0.9]

onready var explode_timer = $ExplodeTimer

func _ready():
	#Random Timer
	var random_at : int = randi() % rndm_explode_time_pool.size()
	var random_timer : float = rndm_explode_time_pool[random_at]
	explode_timer.start(random_timer)

func _on_ExplodeTimer_timeout() -> void:
	var spread_directions : Array = [0, 45, 90, 135, 180]
	
	for i in spread_directions:
		var bullet = watton_bullet.instance()
		get_parent().add_child(bullet)
		bullet.bullet_behavior.angle_in_degrees = i
		bullet.position = self.position
	
	self.queue_free_start(false)