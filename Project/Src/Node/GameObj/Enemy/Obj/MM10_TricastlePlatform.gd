extends EnemyCore


func set_speed(speed : float):
	$BulletBehavior.speed = speed


func fly_toward_player():
	$BulletBehavior.active = true
	
	if player.global_position.x < global_position.x:
		$BulletBehavior.angle_in_degrees = 180
	else:
		$BulletBehavior.angle_in_degrees = 0


func _on_ActivisionTimer_timeout() -> void:
	fly_toward_player()

