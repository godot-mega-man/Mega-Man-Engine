extends TileMap


enum State {
	RAISING,
	FALLING,
	FALL_ENDING,
	DISABLED
}


const MAX_EXTEND_Y = -64


export (float) var raise_speed = 240

export (float) var fall_speed = 15

export (float) var fall_end_speed = 300


var state = State.DISABLED


func _physics_process(delta: float) -> void:
	if state == State.RAISING:
		position.y -= raise_speed * delta
		if position.y < MAX_EXTEND_Y:
			position.y = MAX_EXTEND_Y
			state = State.FALLING
	if state == State.FALLING:
		position.y += fall_speed * delta
		if position.y > Vector2.ZERO.y:
			position.y = Vector2.ZERO.y
			start()
	if state == State.FALL_ENDING:
		position.y += fall_end_speed * delta
		if position.y > Vector2.ZERO.y:
			position.y = Vector2.ZERO.y
			state = State.DISABLED
			Audio.play_sfx("chain_end")


func start():
	if is_player_dead():
		Audio.play_sfx("chain_end")
		state = State.DISABLED
		return
	
	Audio.play_sfx("chain_rise")
	Audio.play_sfx("chain_loop")
	state = State.RAISING


func stop():
	state = State.FALL_ENDING


func is_player_dead() -> bool:
	for i in get_tree().get_nodes_in_group("Player"):
		if i.current_hp <= 0:
			return true
	
	return false


func _exit_tree() -> void:
	Audio.stop_sfx("chain_end")
