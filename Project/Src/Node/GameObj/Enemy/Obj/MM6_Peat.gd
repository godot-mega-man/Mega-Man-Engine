extends EnemyCore


enum State {HIDING, RISING, WAITING, ATTACKING}


const APPEAR_RANGE_X = 80

const DIVE_PLAYER_HEIGHT_OFFSET = -16
const DIVE_SPEED = 300

const MIN_RISE_DURATION = 0.5


var state : int = State.HIDING


func _ready() -> void:
	sprite_main.hide()
	turn_toward_player()
	RANGE_CHECKING_MODE = preset_range_checking_mode.Horizontal


func _physics_process(delta: float) -> void:
	_peat_process()


func rise():
	state = State.RISING
	sprite_main.show()
	$BulletBehavior.active = true
	$RiseDuration.start()
	RANGE_CHECKING_MODE = preset_range_checking_mode.Vertical
	FJ_AudioManager.sfx_combat_peat.play()
	turn_toward_player()


func await_attack():
	$BulletBehavior.active = false
	state = State.WAITING
	$AwaitAttackTimer.start()
	turn_toward_player()


func dive_toward_player():
	state = State.ATTACKING
	$BulletBehavior.active = true
	$BulletBehavior.speed = DIVE_SPEED
	$BulletBehavior.angle_in_degrees = rad2deg(get_angle_to(player.global_position))
	turn_toward_player()


func get_rise_duration() -> float:
	return $RiseDuration.wait_time - $RiseDuration.time_left


func _peat_process():
	match state:
		State.HIDING:
			if abs(get_player_distance()) < APPEAR_RANGE_X:
				rise()
		State.RISING:
			if within_player_range(DIVE_PLAYER_HEIGHT_OFFSET) and get_rise_duration() > MIN_RISE_DURATION:
				await_attack()


func _on_AwaitAttackTimer_timeout() -> void:
	dive_toward_player()


func _on_Peat_slain(target) -> void:
	FJ_AudioManager.sfx_combat_peat.stop()
