extends EnemyCore

#Child nodes
onready var landed_destroy_check = $LandedDestroyCheck
onready var platformer_behavior = $PlatformerBehavior

var on_floor_time = 0

func _process(delta: float) -> void:
	if is_on_floor():
		on_floor_time += 1
		if on_floor_time > 5:
			return
		
		for i in landed_destroy_check.get_overlapping_bodies():
			var player = i
			if i != null and i is Player:
				#Hard coded. need to reduce or remove multi-check cond. 
				if !(i as Player).is_invincible:
					(i as Player).player_take_damage(STRENGTH)
				DROP_COIN = false
				EXP_REWARD = 0
				self.hit_by_player_projectile(self.HP, 0, null)
				return
	if platformer_behavior.velocity.y > 0:
		on_floor_time = 0