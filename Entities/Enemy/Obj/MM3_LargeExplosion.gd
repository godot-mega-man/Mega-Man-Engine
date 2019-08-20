#Large Explosion Enemy
#Code by: First

#This is just like a large explosion effect, but also
#capable of damaging player. Useful for enemies like
#bomb thrower that throws bomb projectile and spawn this node
#upon impact. 

extends EnemyCore

#Child nodes
onready var damage_area_col = $DamageArea/CollisionShape2D

func _on_DamageAreaDeactivationTimer_timeout() -> void:
	damage_area_col.call_deferred("set_disabled", true)

func _on_QueueFreeTimer_timeout() -> void:
	queue_free_start(false)
