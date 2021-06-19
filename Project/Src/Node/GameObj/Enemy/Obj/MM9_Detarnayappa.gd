extends EnemyCore

enum State {
	READY,
	UP,
	ATTACKING,
	FALLING,
	HIDING
}

const DETECT_RANGE_H = 48
const DETECT_RANGE_Y = -16
const BULLET = preload("res://Src/Node/GameObj/Enemy/Obj/MM2_Bullet.tscn")
const BULLET_SPEED = 150
const BULLET_DAMAGE = 2
const HIDE_COOLDOWN = 0.7

var state = State.READY
onready var initial_gpos : Vector2 = global_position

func _ready() -> void:
	if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
		$BulletBehaviorUp.speed *= 2
	
	RANGE_CHECKING_MODE = 1
	$SpriteMain/Sprite/AnimationPlayer.play("Initial")

func _physics_process(delta: float) -> void:
	if state == State.READY:
		if abs(get_player_distance()) < DETECT_RANGE_H:
			$BulletBehaviorUp.active = true
			state = State.UP
			RANGE_CHECKING_MODE = 2
			sprite_main.show()
	if state == State.UP:
		if get_player_distance() < DETECT_RANGE_Y:
			$BulletBehaviorUp.active = false
			start_attack()
			state = State.ATTACKING
	if state == State.FALLING:
		if global_position.y > initial_gpos.y:
			$SpriteMain/Sprite/AnimationPlayer.play("Initial")
			$BulletBehaviorDown.active = false
			state = State.HIDING
			RANGE_CHECKING_MODE = 1
			prepare_new_state()

func start_attack():
	$SpriteMain/Sprite/AnimationPlayer.play("Open")
	yield($SpriteMain/Sprite/AnimationPlayer, "animation_finished")
	fire()
	$BulletBehaviorDown.current_gravity = 0
	$BulletBehaviorDown.active = true
	state = State.FALLING

func fire():
	var directions : Array
	
	if Difficulty.difficulty == Difficulty.DIFF_NEWCOMER:
		directions = [0, 180]
	if Difficulty.difficulty == Difficulty.DIFF_CASUAL:
		directions = [0, 180]
	if Difficulty.difficulty == Difficulty.DIFF_NORMAL:
		directions = [15, -15, 165, 195]
	if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
		directions = [0, 180, 15, -15, 165, 195]
	
	
	for i in directions:
		var blt = BULLET.instance()
		blt.contact_damage = BULLET_DAMAGE
		get_parent().add_child(blt)
		blt.global_position = global_position
		blt.bullet_behavior.speed = BULLET_SPEED
		blt.bullet_behavior.angle_in_degrees = i
	
	Audio.play_sfx("enemy_shot")

func prepare_new_state():
	yield(get_tree().create_timer(HIDE_COOLDOWN), "timeout")
	state = State.READY
