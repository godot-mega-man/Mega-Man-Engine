extends EnemyCore

const BULLET_DAMAGE = 2
const SHADOW_BLADE = preload("res://Src/Node/GameObj/Enemy/Obj/MM3_ShadowBladeSmall.tscn")
const BULLET = preload("res://Src/Node/GameObj/Enemy/Obj/MM2_Bullet.tscn")

export (PackedScene) var enemy_explosion
export (float) var explode_countdown_time = 0.7

onready var pf_bhv := $PlatformBehavior as FJ_PlatformBehavior2D
onready var dmg_area = $DamageArea

var landed : bool

func explode_countdown():
	$ExplodeTimer.start()

func explode():
	var en = enemy_explosion.instance()
	get_parent().add_child(en)
	en.global_position = self.global_position
	en.contact_damage = self.contact_damage
	
	FJ_AudioManager.sfx_combat_large_explosion.play()
	
	if Difficulty.difficulty >= Difficulty.DIFF_NORMAL:
		split_shadow_blades()
	
	queue_free_start(false)

func split_shadow_blades():
	var angles : Array = [-105, -75]
	
	if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
		angles.append(-120)
		angles.append(-60)
	
	for i in angles:
		var blt = SHADOW_BLADE.instance()
		blt.contact_damage = 3
		get_parent().add_child(blt)
		blt.global_position = self.global_position
		blt.bullet_behavior.angle_in_degrees = i
		blt.bullet_behavior.gravity = 600
		blt.bullet_behavior.max_fall_speed = 450
		blt.bullet_behavior.speed = 240
		blt.bullet_behavior.acceleration = -120


func _on_ExplodeTimer_timeout() -> void:
	$ExplodeFlashTimer.start(explode_countdown_time)
	$SpriteMain/Sprite/Anim.play("Flashing")

func _on_ExplodeFlashTimer_timeout() -> void:
	explode()

func _on_PlatformBehavior_landed() -> void:
	if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
		explode()
	
	FJ_AudioManager.sfx_combat_hop.play()


func _on_MM9_c_HooHooBomb_taking_damage(value, target, player_proj_source) -> void:
	if player_proj_source.projectile_name == "ring":
		event_damage = 2
