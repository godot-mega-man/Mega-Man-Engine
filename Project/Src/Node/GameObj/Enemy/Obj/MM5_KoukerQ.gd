extends EnemyCore


const DETECT_RANGE = 24


func _ready() -> void:
	if global_position.x < player.global_position.x:
		queue_free()


func _process(delta: float) -> void:
	if within_player_range(DETECT_RANGE):
		stall()


func stall():
	$SpriteMain/Sprite/Anim.play("Stall")


func fall():
	$BulletBehavior.active = false
	$PlatformBehavior.INITIAL_STATE = true
	Audio.play_sfx("fall")
