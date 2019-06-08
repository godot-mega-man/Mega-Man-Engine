extends EnemyCore

export(PackedScene) var shoot_projectile
export(float) var attack_range = 130

#Child nodes
onready var joe_animation = $JoeAnimation
onready var platformer_behavior = $PlatformerBehavior
onready var flip = $Flip
onready var fire_bullet = $Flip/FireBullet
onready var attack_cooldown_timer = $AttackCooldownTimer
onready var gun_sound = $GunSound
onready var projectile_reflector = $Flip/ShieldArea2D/ProjectileReflector

onready var player = get_node("/root/Level/Iterable/Player")

#Temp
var is_attack_ready : bool = false
var is_attacking : bool = false

#Preloading obj
var joe_bullet = preload("res://DEV_ExampleUsages/Ex_LevelCreationTest/MegaMan_Level/EnemyObj/JoeMachineGunBullet.tscn")

func _ready() -> void:
	if player == null:
		push_warning(str(self.name, ": Player was not found. Stopping AI."))

func _process(delta: float) -> void:
	if player != null:
		var actual_player = player as Player
		var distance : float = actual_player.global_position.x - self.global_position.x
		
		if abs(distance) < attack_range && is_attack_ready:
			if randi() % 3 + 1 == 1:
				joe_animation.play("Jump")
				platformer_behavior.jump_start()
			else:
				joe_animation.play("Shoot")
			is_attack_ready = false
			is_attacking = true

func fire():
	var bullet = joe_bullet.instance()
	get_parent().add_child(bullet)
	bullet.global_position = fire_bullet.global_position
	bullet.bullet_behavior.angle_in_degrees = 0 if flip.scale.x == -1 else 180
	
	gun_sound.play()

func _on_AttackedCooldownTimer_timeout() -> void:
	is_attack_ready = true

func attack_done():
	standby()

func standby():
	attack_cooldown_timer.start()
	joe_animation.play("Idle")
	is_attacking = false
	projectile_reflector.enabled = true

#Turn towards player while not shooting.
func _on_PointTowardPlayerInterval_timeout() -> void:
	turn_towards_player()

func turn_towards_player():
	if player != null:
		if is_attacking:
			return
		
		var actual_player = player as Player
		if actual_player.global_position.x > self.global_position.x:
			flip.scale.x = -1
		else:
			flip.scale.x = 1

func _on_PlatformerBehavior_landed() -> void:
	if joe_animation.current_animation == "Jump":
		standby()
