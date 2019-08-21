extends EnemyProjectile

var h_flame = preload("res://Entities/Enemy/Obj/MM6_FlameBurstHorizontal.tscn")
var v_flame = preload("res://Entities/Enemy/Obj/MM6_FlameBurstVertical.tscn")

func _on_PlatformBehavior_landed() -> void:
	var enemy_flame_obj = v_flame.instance()
	get_parent().add_child(enemy_flame_obj)
	enemy_flame_obj.global_position = global_position
	
	FJ_AudioManager.sfx_combat_flame_burst.play()
	
	queue_free()

func _on_PlatformBehavior_by_wall() -> void:
	var enemy_flame_obj = h_flame.instance()
	get_parent().add_child(enemy_flame_obj)
	enemy_flame_obj.global_position = global_position
	
	if bullet_behavior.angle_in_degrees < -90:
		enemy_flame_obj.scale.x = -1
	
	FJ_AudioManager.sfx_combat_flame_burst.play()
	
	queue_free()
