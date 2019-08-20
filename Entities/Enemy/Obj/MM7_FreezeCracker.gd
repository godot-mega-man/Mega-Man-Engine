extends EnemyProjectile

onready var area = $Area2D

export (PackedScene) var debris
export (PackedScene) var ice_shard_effect
export (PackedScene) var icicle

var behavior_type = 0 #0 : Freeze Cracker
					  #1 : Floor Flood
					  #2 : Icicle Spawn

func _physics_process(delta: float) -> void:
	var bodies = area.get_overlapping_bodies()
	
	for i in bodies:
		if i is TileMap:
			if behavior_type == 0:
				spread_freeze_debris()
			if behavior_type == 1:
				spread_freeze_debris()
			if behavior_type == 2:
				spawn_icicles()
			
			create_shard_effects()
			queue_free()

#effect
func create_shard_effects():
	var directions = [-10, -45, -90, -135, -170]
	for i in directions:
		var effect = ice_shard_effect.instance()
		get_parent().add_child(effect)
		effect.position = self.position
		effect.bullet_bhv.angle_in_degrees = i
		effect.bullet_bhv.speed = rand_range(20, 120)

func spread_freeze_debris():
	var spread_angles_in_degrees = 6
	for i in spread_angles_in_degrees:
		var proj = debris.instance()
		get_parent().add_child(proj)
		proj.bullet_behavior.angle_in_degrees = i * (360 / spread_angles_in_degrees)
		proj.global_position = self.global_position
	
	FJ_AudioManager.sfx_combat_ice_break.play()

func spawn_icicles():
	var current_position = self.position
	
	var delay_start : float = rand_range(0.01, 0.5)
	
	#Right then Left
	for i in 7:
		var icicle_projectile = icicle.instance()
		icicle_projectile.delay = i * 0.5
		get_parent().add_child(icicle_projectile)
		icicle_projectile.global_position = self.global_position + Vector2(0, 10)
		icicle_projectile.global_position.x += i * 32
		icicle_projectile.pickups_drop_enabled = false
	for i in 6:
		var icicle_projectile = icicle.instance()
		icicle_projectile.delay = delay_start + i * 0.5
		get_parent().add_child(icicle_projectile)
		icicle_projectile.global_position = self.global_position + Vector2(-32, 10)
		icicle_projectile.global_position.x -= i * 32
		icicle_projectile.pickups_drop_enabled = false
