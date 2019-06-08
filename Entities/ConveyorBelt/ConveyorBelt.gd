tool
extends StaticBody2D

#NOTE WHEN CHANGING CONVEYOR'S LENGTH IN BLOCKS, ALL SHAPES MUST USE
#THE FOLLOWING CODE: shape.new(rect_shape)

export(bool) var enabled = true
export(int, 1, 512) var size = 3 setget _set_size
export(Vector2) var travel_speed_per_second = Vector2(90, 0) #Positive value go right, negative go left.

#Child nodes
onready var collision_shape = $CollisionShape2D
onready var travel_area = $TravelArea2D
onready var travel_collision_shape = travel_area.get_node("CollisionShape2D")

#GETTER/SETTER
func _set_size(new_value):
	size = new_value
	_update_conveyor_size()

func _physics_process(delta) -> void:
	if Engine.is_editor_hint():
		return
	
	for i in travel_area.get_overlapping_bodies():
		if i is KinematicBody2D:
			if i.is_on_floor():
				i.move_and_slide(travel_speed_per_second, Vector2(0, -1))

func _update_conveyor_size():
	if(size == 1):
		_set_sprite_visible(get_node_or_null("LoopSprite"), false)
		_set_sprite_visible(get_node_or_null("EndSprite"), false)
	if(size >= 2):
		_set_sprite_visible(get_node_or_null("LoopSprite"), false)
		_set_sprite_visible(get_node_or_null("EndSprite"), true)
		#Set position of the end_sprite.
		if has_node("EndSprite"):
			get_node("EndSprite").position.x = 16 + (16 * (size - 2))
	if(size >= 3):
		_set_sprite_visible(get_node_or_null("LoopSprite"), true)
		_set_sprite_visible(get_node_or_null("EndSprite"), true)
		#Set size, position of the loop_sprite.
		if has_node("LoopSprite"):
			if !Engine.is_editor_hint():
				for i in size - 3:
					var additional_piece = get_node("LoopSprite").duplicate()
					add_child(additional_piece)
					additional_piece.position.x = 32 + (16 * i)
			else:
				get_node("LoopSprite").scale.x = size - 2
				get_node("LoopSprite").position.x = 8 + (8 * (size - 2))
	
	#Update collision size of both static body and TravelArea.
	if has_node("CollisionShape2D"):
		var new_shape = RectangleShape2D.new()
		new_shape.extents = Vector2(size * 8, 8)
		get_node("CollisionShape2D").shape = new_shape
		get_node("CollisionShape2D").position.x = -8 + (size * 8)
	if has_node("TravelArea2D/CollisionShape2D"):
		var new_shape = RectangleShape2D.new()
		new_shape.extents = Vector2(size * 8, 4)
		get_node("TravelArea2D/CollisionShape2D").shape = new_shape
		get_node("TravelArea2D/CollisionShape2D").position.x = -8 + (size * 8)

func _set_sprite_visible(var node : Node, var set : bool):
	if node != null && node is Sprite:
		node.visible = set