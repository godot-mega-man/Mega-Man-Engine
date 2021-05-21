extends PlayerProjectile

const PICKUP_GRAB_SHIFT = Vector2(0, -1)

var state : int
var projectile_owner : Node2D
var destroy_distance_owner = 4
var pickups_grab_range = 16
var consume_ammo_on_hold : bool = true


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
			queue_free()
	
	grab_pickups()

func _on_FireDurationTimer_timeout() -> void:
	bullet_behavior.active = false
	state = 1
	$PlatformKineBody/CollisionShape2D.disabled = false
	$HoldAmmoConsumeInterval.start()

func _on_HoldAmmoConsumeInterval_timeout() -> void:
	if state != 1:
		return
	
	if GameHUD.player_weapon_bar.frame > 0 and consume_ammo_on_hold:
		GameHUD.player_weapon_bar.frame -= 1
	if GameHUD.player_weapon_bar.frame <= 0:
		bullet_behavior.active = true
		$PlatformKineBody/CollisionShape2D.disabled = true
		state = 2

func grab_pickups():
	for i in get_tree().get_nodes_in_group("Pickups"):
		i = i as Node2D
		
		if global_position.distance_to(i.global_position) < pickups_grab_range:
			i.global_position = global_position + PICKUP_GRAB_SHIFT
			i.pf_bhv.velocity = Vector2.ZERO


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
