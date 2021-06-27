extends Node2D


var thiuns = preload("res://Src/Node/GameObj/Effects/MM_Thiun/Thiun.tscn")

var speed = [240, 120]

var degrees_increment = 45

var create_count = 8


export(NodePath) var create_target


func create() -> void:
	if create_target == null:
		return
	
	for s in speed:
		for i in create_count:
			var eff = thiuns.instance()
			get_node(create_target).call_deferred("add_child", eff)
			eff.get_node("BulletBehavior").angle_in_degrees = degrees_increment * i
			eff.get_node("BulletBehavior").speed = s
			eff.global_position = self.global_position
