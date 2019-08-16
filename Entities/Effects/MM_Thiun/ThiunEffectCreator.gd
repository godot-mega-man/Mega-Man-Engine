extends Node2D

var thiuns = preload("res://Entities/Effects/MM_Thiun/Thiun.tscn")

export(NodePath) var create_target

func create() -> void:
	if create_target == null:
		printerr('create target is null. Returned 0.')
		return
	
	var speed = [60,120]
	var degrees_increment = 45
	var create_count = 8
	
	for i in speed:
		for j in create_count:
			var eff = thiuns.instance()
			get_node(create_target).call_deferred("add_child", eff)
			eff.get_node("BulletBehavior").angle_in_degrees = degrees_increment * j
			eff.get_node("BulletBehavior").speed = i
			eff.global_position = self.global_position
