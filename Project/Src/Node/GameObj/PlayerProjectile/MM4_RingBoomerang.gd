extends PlayerProjectile

const PICKUP_GRAB_SHIFT = Vector2(0, -1)

var state : int
var projectile_owner : Node2D
var destroy_distance_owner = 4
var pickups_grab_range = 16

func _physics_process(delta: float) -> void:
	if is_reflected:
		$FireDurationTimer.stop()
		$HoldAmmoConsumeInterval.stop()
		state == -1
		return
	
	if state == 1:
		if not Input.is_action_pressed("game_action") or is_player_dead():
			_angle_toward_player()
			bullet_behavior.active = true
			$PlatformKineBody/CollisionShape2D.disabled = true
			state = 2
	elif state == 2:
		_angle_toward_player()
		
		if self.global_position.distance_to(projectile_owner.global_position) < destroy_distance_owner:
			refund_energy()
			queue_free()
	
	grab_pickups()

func _on_FireDurationTimer_timeout() -> void:
	bullet_behavior.active = false
	state = 1
	$PlatformKineBody/CollisionShape2D.disabled = false
	$HoldAmmoConsumeInterval.start(0.5)

func _on_HoldAmmoConsumeInterval_timeout() -> void:
	if state != 1:
		return
	
	if GameHUD.player_weapon_bar.frame > 0:
		GameHUD.player_weapon_bar.frame -= 1
	else:
		bullet_behavior.active = true
		$PlatformKineBody/CollisionShape2D.disabled = true
		state = 2

func grab_pickups():
	for i in get_tree().get_nodes_in_group("Pickups"):
		i = i as Node2D
		
		if global_position.distance_to(i.global_position) < pickups_grab_range:
			i.global_position = global_position + PICKUP_GRAB_SHIFT
			i.pf_bhv.velocity = Vector2.ZERO

func refund_energy():
	if randi() % 6 == 0:
		return
	
	if GameHUD.player_weapon_bar.frame < 28:
		GameHUD.player_weapon_bar.frame += 1

func is_player_dead() -> bool:
	for i in get_tree().get_nodes_in_group("Player"):
		if i.current_hp <= 0:
			return true
	
	return false

func _angle_toward_player():
	if is_player_dead():
		return
	
	var ag = self.global_position.angle_to_point(projectile_owner.global_position)
	bullet_behavior.angle_in_degrees = rad2deg(ag) - 180
