class_name TricastleEyes extends EnemyCore


const PEEK_DOWN_WIDTH = 32

const FRAME_PEEK_CENTER = 0
const FRAME_PEEK_UP_LEFT = 5
const FRAME_PEEK_UP_RIGHT = 6
const FRAME_PEEK_DOWN_LEFT = 7
const FRAME_PEEK_DOWN_RIGHT = 8
const FRAME_PEEK_DOWN_CENTER = 9


enum FaceType {DOOR, TOWER}

export (FaceType) var face_type = FaceType.DOOR


var _peek_target : Node2D


func _process(delta: float) -> void:
	_do_peek()


func blink():
	$SpriteMain/AnimationPlayer.play("Blink")


func set_peek_target(new_target : Node2D):
	if new_target == null:
		sprite.frame = 0
	
	_peek_target = new_target


func release_bird():
	if face_type != FaceType.TOWER:
		return
	
	var peat = preload("res://Src/Node/GameObj/Enemy/Obj/MM6_Peat.tscn").instance()
	get_objects_node().add_child(peat)
	peat.global_position = global_position
	peat.position += Vector2(0, -24)
	peat.rise()
	peat.pickups_drop_enabled = false


# Returns the node that usually contains game object
# Returns parent instead if not exist.
func get_objects_node():
	var sprite_cys = get_tree().get_nodes_in_group("SpriteCycling")
	
	if sprite_cys.empty():
		return get_parent()
	
	return sprite_cys.front().get_parent()


func _do_peek():
	if _peek_target == null:
		return
	if _peek_target != null and not is_instance_valid(_peek_target):
		return
	
	var lookat_pos = _peek_target.global_position
	
	if lookat_pos.y > global_position.y:
		
		if lookat_pos.x < global_position.x - PEEK_DOWN_WIDTH:
			sprite.frame = FRAME_PEEK_DOWN_LEFT
			return
		
		if lookat_pos.x > global_position.x + PEEK_DOWN_WIDTH:
			sprite.frame = FRAME_PEEK_DOWN_RIGHT
			return
		
		sprite.frame = FRAME_PEEK_DOWN_CENTER
		return
	
	if lookat_pos.x < global_position.x - PEEK_DOWN_WIDTH:
		sprite.frame = FRAME_PEEK_UP_LEFT
	
	if lookat_pos.x > global_position.x + PEEK_DOWN_WIDTH:
		sprite.frame = FRAME_PEEK_UP_RIGHT
