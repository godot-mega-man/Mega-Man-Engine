extends EnemyCore


export (float) var frame_wait = 2


var curr_frame : float

var limit : int


func _ready() -> void:
	init_camera_limits()


func _process(delta: float) -> void:
	if player.current_hp <= 0:
		return
	
	var cam = get_camera()
	
	curr_frame += delta * 60
	if curr_frame < frame_wait:
		return
	
	cam.limit_left += 1
	cam.limit_right += 1
	position.x += 1
	curr_frame -= frame_wait
	
	# Move killer static body to where the player could get killed from
	# being stucked
	$KillerStaticCollisionVertical.global_position = Vector2(
		cam.limit_left - 8,
		cam.limit_top + (cam.limit_bottom - cam.limit_top)
	)
	
	if cam.limit_right >= limit:
		queue_free()


func get_camera() -> Camera2D:
	var cams = get_tree().get_nodes_in_group("CameraCustom")
	
	if cams.empty():
		return null
	
	return cams.back()


func init_camera_limits():
	limit = get_camera().limit_right
	get_camera().limit_right = get_camera().limit_left + 256

