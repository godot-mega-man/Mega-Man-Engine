extends EnemyCore

export (PackedScene) var large_explosion_enemy
export(int) var flash_count_b4_explode = 3

onready var count_bomb_ani = $SpriteMain/Sprite/CountBombAni
onready var landing_checker = $LandingChecker

#Temp
var pressed = false

func _process(delta: float) -> void:
	if pressed:
		return
	
	var overlapping_areas = landing_checker.get_overlapping_areas()
	
	for i in overlapping_areas:
		var owner = i.get_owner()
		if owner is KinematicBody2D:
			if owner.has_node("PlatformBehavior"):
				var pf_bhv = owner.get_node("PlatformBehavior") as FJ_PlatformBehavior2D
				
				if pf_bhv.on_floor:
					press()

func press():
	if pressed:
		return
	else:
		pressed = true
		count_bomb_ani.play("Countdown")

func bomb_time_out():
	count_bomb_ani.play("Exploding")

func decrease_flash_count():
	if flash_count_b4_explode <= 0:
		explode()
		return
	flash_count_b4_explode -= 1

func explode():
	FJ_AudioManager.sfx_combat_large_explosion.play()
	
	var inst_enemy_obj = large_explosion_enemy.instance()
	get_parent().add_child(inst_enemy_obj)
	inst_enemy_obj.position = self.position
	inst_enemy_obj.contact_damage = contact_damage
	
	queue_free()