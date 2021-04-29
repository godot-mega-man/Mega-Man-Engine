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
			FJ_AudioManager.sfx_env_chain_loop.stop()
			FJ_AudioManager.sfx_env_chain_end.play()

func start():
	if is_player_dead():
		FJ_AudioManager.sfx_env_chain_end.play()
		state = State.DISABLED
		return
	
	FJ_AudioManager.sfx_env_chain_raise.play()
	FJ_AudioManager.sfx_env_chain_loop.play()
	state = State.RAISING

func stop():
	state = State.FALL_ENDING

func is_player_dead() -> bool:
	for i in get_tree().get_nodes_in_group("Player"):
		if i.current_hp <= 0:
			return true
	
	return false

func _exit_tree() -> void:
	FJ_AudioManager.sfx_env_chain_loop.stop()
