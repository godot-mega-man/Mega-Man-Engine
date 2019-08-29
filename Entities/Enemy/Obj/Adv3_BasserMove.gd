extends EnemyCore

onready var bullet_bhv = $BulletBehavior

func _ready():
	if player != null:
		if player.global_position.x < global_position.x:
			bullet_bhv.angle_in_degrees = 180
		else:
			bullet_bhv.angle_in_degrees = 0
