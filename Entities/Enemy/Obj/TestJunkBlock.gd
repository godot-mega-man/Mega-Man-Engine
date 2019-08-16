extends EnemyCore

#Child nodes
onready var landed_destroy_check = $LandedDestroyCheck
onready var platformer_behavior = $PlatformBehavior

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
				if !i.is_invincible:
					i.player_take_damage(database.general.combat.contact_damage)
				database.loots.coin.drop_coin = false
				database.loots.experience.exp_awarded = 0
				database.loots.diamond.drop_diamond = false
				database.loots.item_table.enabled = false
				self.hit_by_player_projectile(database.general.stats.hit_points_base, null)
				return
	if platformer_behavior.velocity.y > 0:
		on_floor_time = 0