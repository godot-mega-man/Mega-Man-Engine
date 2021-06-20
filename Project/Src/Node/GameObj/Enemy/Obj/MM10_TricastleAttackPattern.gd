extends Node


enum State {
	IDLE,
	INITIAL,
	LEFT_TOWER_ATTACK,
	RIGHT_TOWER_ATTACK,
	REPEATING_SEQUENCE
}


const ATTACK_ANIMATION_DELAY = 0.55

const ATTACK_PREPARE_DURATION = 0.7
const ATTACK_MID_PEEK_DURATION = 0.8
const ATTACK_MID_AWAIT_DURATION = 0.2
const ATTACK_TOWER_SKIP_DURATION = 0.2
const ATTACK_TOWER_PEEK_DURATION = 0.8
const ATTACK_SEQUENCE_REPEAT_AWAIT_DURATION = 1.2


export var eyes_tower_left : NodePath
export var eyes_tower_right : NodePath
export var eyes_middle : NodePath
export var door : NodePath
export var platform_spawner : NodePath


onready var player = $"/root/Level/Iterable/Player" # Sorry!


var active : bool

var state : int = State.INITIAL


func _ready() -> void:
	assert(not eyes_tower_left.is_empty())
	assert(not eyes_tower_right.is_empty())
	assert(not eyes_middle.is_empty())
	assert(not door.is_empty())
	assert(not platform_spawner.is_empty())


func _process(delta: float) -> void:
	_do_attack_process()


func start():
	active = true


func stop():
	active = false


func _do_attack_process():
	if not active:
		return
	
	if state == State.INITIAL:
		prepare()
	if state == State.RIGHT_TOWER_ATTACK:
		tower_attack(eyes_tower_right, State.LEFT_TOWER_ATTACK)
		state = State.IDLE
	if state == State.LEFT_TOWER_ATTACK:
		tower_attack(eyes_tower_left, State.REPEATING_SEQUENCE)
		state = State.IDLE
	if state == State.REPEATING_SEQUENCE:
		repeat_sequence()
		state = State.IDLE


func prepare():
	state = State.IDLE
	$PrepareTimer.start(ATTACK_PREPARE_DURATION)


func open_door():
	get_node_or_null(platform_spawner).spawn()
	
	if get_node_or_null(eyes_middle) != null:
		get_node_or_null(eyes_middle).set_peek_target(get_node_or_null(door))
		get_node_or_null(door).open()
		yield(get_tree().create_timer(ATTACK_MID_PEEK_DURATION), "timeout")
	
	if get_node_or_null(eyes_middle) != null:
		get_node_or_null(eyes_middle).set_peek_target(null)
		yield(get_tree().create_timer(ATTACK_MID_AWAIT_DURATION), "timeout")
	
	state = State.RIGHT_TOWER_ATTACK


func tower_attack(eyes_tower_path : NodePath, next_state : int):
	if get_node_or_null(eyes_tower_path) == null:
		yield(get_tree().create_timer(ATTACK_TOWER_SKIP_DURATION), "timeout")
		state = next_state
		return
	
	if get_node_or_null(eyes_middle) != null and get_node_or_null(eyes_tower_path) != null:
		get_node_or_null(eyes_tower_path).blink()
		get_node_or_null(eyes_middle).blink()
		yield(get_tree().create_timer(ATTACK_ANIMATION_DELAY), "timeout")
	if get_node_or_null(eyes_middle) != null and get_node_or_null(eyes_tower_path) != null:
		get_node_or_null(eyes_tower_path).set_peek_target(get_node_or_null(eyes_middle))
		get_node_or_null(eyes_middle).set_peek_target(get_node_or_null(eyes_tower_path))
		get_node_or_null(eyes_tower_path).release_bird()
		yield(get_tree().create_timer(ATTACK_TOWER_PEEK_DURATION), "timeout")
	if get_node_or_null(eyes_middle) != null and get_node_or_null(eyes_tower_path) != null:
		get_node_or_null(eyes_tower_path).set_peek_target(null)
		get_node_or_null(eyes_middle).set_peek_target(null)
	
	if get_node_or_null(eyes_middle) == null and get_node_or_null(eyes_tower_path) != null:
		get_node_or_null(eyes_tower_path).release_bird()
		get_node_or_null(eyes_tower_path).set_peek_target(player)
		yield(get_tree().create_timer(ATTACK_TOWER_PEEK_DURATION * 2), "timeout")
	if get_node_or_null(eyes_middle) == null and get_node_or_null(eyes_tower_path) != null:
		get_node_or_null(eyes_tower_path).set_peek_target(null)
	
	state = next_state


func repeat_sequence():
	var duration_modifier = 0.2
	
	if get_node_or_null(eyes_tower_left) == null:
		duration_modifier += 0.4
	if get_node_or_null(eyes_tower_right) == null:
		duration_modifier += 0.4
	
	yield(get_tree().create_timer(ATTACK_SEQUENCE_REPEAT_AWAIT_DURATION * duration_modifier), "timeout")
	state = State.INITIAL


func _on_PrepareTimer_timeout() -> void:
	open_door()
