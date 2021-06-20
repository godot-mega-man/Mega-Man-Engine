extends EnemyCore


const ANIM_IDLE = "Idle"
const ANIM_JUMP = "Jump"
const ANIM_SHIELDED = "Shielded"
const ANIM_SHOOT = "Shoot"

const SUICIDE_SHIFT_OFFSET = Vector2(0, -128)
const ONE_UP = preload("res://Src/Node/GameObj/Pickups/Life.tscn")


export(PackedScene) var shoot_projectile
export(float) var attack_range = 130
export var always_jump : bool


onready var anim = $Anim
onready var platformer_behavior = $PlatformBehavior
onready var fire_bullet = $SpriteMain/FireBullet
onready var projectile_reflector = $SpriteMain/ShieldArea2D/ProjectileReflector


func _ready() -> void:
	if Difficulty.difficulty == Difficulty.DIFF_NEWCOMER:
		current_hp = 2
	if Difficulty.difficulty == Difficulty.DIFF_CASUAL:
		current_hp = 3
	if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
		current_hp = 6
	
	anim.play("Idle")


func fire():
	var bullet = shoot_projectile.instance()
	get_parent().add_child(bullet)
	bullet.global_position = fire_bullet.global_position
	if bullet.has_node("BulletBehavior"):
		# Shoot straight
		bullet.bullet_behavior.angle_in_degrees = 0 if sprite_main.scale.x == -1 else 180
	
	Audio.play_sfx("enemy_shot")


func attack_done():
	standby()


func standby():
	anim.play("Idle")


func begin_attack():
	if randi() % 10 < 4 or always_jump:
		anim.play("Jump")
		jump()
		return
	
	if Difficulty.difficulty <= Difficulty.DIFF_NORMAL:
		anim.play("Shoot")
	if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
		anim.play("Shoot II")
	


func jump():
	platformer_behavior.jump_start()


func suicide_with_1up():
	# Create effect at the current position before the enemy moves
	var effect = explosion_effect.instance()
	get_parent().add_child(effect)
	effect.global_position = self.global_position
	
	pickups_drop_enabled = false
	current_hp = 0
	global_position += SUICIDE_SHIFT_OFFSET
	check_for_death()
	
	var life_en = ONE_UP.instance()
	get_parent().add_child(life_en)
	life_en.global_position = global_position


func _on_Anim_animation_finished(anim_name: String) -> void:
	match anim_name:
		ANIM_IDLE:
			begin_attack()
		ANIM_SHOOT:
			standby()
		ANIM_SHIELDED:
			standby()
		ANIM_JUMP:
			pass


func _on_PointTowardPlayerInterval_timeout() -> void:
	turn_toward_player()


func _on_PlatformerBehavior_landed() -> void:
	if anim.current_animation == "Jump":
		standby()


func _on_ProjectileReflector_reflected() -> void:
	anim.stop()
	anim.play("Shielded")


func _on_PlatformBehavior_crushed() -> void:
	suicide_with_1up()
