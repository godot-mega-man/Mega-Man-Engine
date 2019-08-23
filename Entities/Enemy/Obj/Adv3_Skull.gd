extends EnemyCore

export (int) var number_of_fireball = 2

var flameburst_fireball = preload("res://Entities/Enemy/Obj/MM6_FlameBurstFireball.tscn")

func _on_Skull_taken_damage(value, target, player_proj_source) -> void:
	for i in number_of_fireball:
		var fireball
		
		fireball = flameburst_fireball.instance()
		get_parent().add_child(fireball)
		fireball.global_position = global_position
		fireball.bullet_behavior.angle_in_degrees = rand_range(-200, -110)
		
		fireball = flameburst_fireball.instance()
		get_parent().add_child(fireball)
		fireball.global_position = global_position
		fireball.bullet_behavior.angle_in_degrees = rand_range(-70, 20)
		
		
