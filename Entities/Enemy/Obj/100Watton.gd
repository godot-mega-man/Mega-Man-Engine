extends EnemyCore

export (PackedScene) var launch_projectile = preload("res://Entities/Enemy/Obj/100WattonBomb.tscn")
export (PackedScene) var launch_smoke_effect = preload("res://Entities/Effects/100WattonSmokeEffect/100WattonSmokeEffect.tscn")

onready var bullet_behavior = $BulletBehavior
onready var bomb_launcher_position = $BombLauncherPosition
onready var smoke_launcher_position = $SmokeLauncherPosition
onready var atk_timer = $AttackTimer
onready var atk_wait_timer = $AttackWaitTimer

#Temp
var fixed_initial_angle : float = 0

func _ready():
	fly_toward_player()

func fly_toward_player():
	if player == null:
		return
	
	if player.global_position.x < self.global_position.x:
		fixed_initial_angle = 180
	else:
		fixed_initial_angle = 0
	bullet_behavior.angle_in_degrees = fixed_initial_angle

func _on_AttackTimer_timeout() -> void:
	set_flying(false)
	launch_100_watton_bomb()
	atk_wait_timer.start()

func _on_AttackWaitTimer_timeout() -> void:
	set_flying(true)
	atk_timer.start()

func set_flying(var set : bool):
	bullet_behavior.active = set

func launch_100_watton_bomb():
	var bomb = launch_projectile.instance()
	get_parent().add_child(bomb)
	bomb.position = self.position + bomb_launcher_position.position

func _on_LaunchSmokeEffectTimer_timeout() -> void:
	var smoke_eff = launch_smoke_effect.instance()
	get_parent().add_child(smoke_eff)
	smoke_eff.position = self.position + smoke_launcher_position.position

#When dies, dim the level brightness!
func _on_100Watton_slain(target) -> void:
	get_node("/root/LevelBrightness").toggle_brightness(true, 15)
