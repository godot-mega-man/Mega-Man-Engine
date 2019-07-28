extends EnemyProjectile

export (float) var delay = 0

onready var damage_area = $DamageArea
onready var damage_area_col = $DamageArea/CollisionShape2D
onready var ici_ani = $SpriteMain/Sprite/IciAni
onready var delay_start_timer = $DelayStartTimer

var is_destroyed = false

var ice_shard_effect = preload("res://DEV_ExampleUsages/Ex_LevelCreationTest/MegaMan_Level/Effects/IceShardEffect.tscn")

func _ready() -> void:
	if delay == 0:
		start_make()
	else:
		delay_start_timer.start(delay)

func start_make():
	ici_ani.play("New Anim")
	damage_area_col.call_deferred("set_disabled", false)
	FJ_AudioManager.sfx_combat_ice_make.play()

func destroy():
	FJ_AudioManager.sfx_combat_ice_break.play()
	self.visible = false
	damage_area_col.call_deferred("set_disabled", true)
	destroy_ice_floor()
	create_shard_effects()
	ici_ani.play("Destroying")
	bullet_behavior.active = false

func _physics_process(delta: float) -> void:
	#the area won't check if it's just falling
	if bullet_behavior.current_distance_traveled < 16:
		return
	
	var bodies = damage_area.get_overlapping_bodies()
	
	for i in bodies:
		if i is TileMap:
			if !is_destroyed:
				destroy()
				is_destroyed = true

func destroy_ice_floor():
	pass

func create_shard_effects():
	var directions = [-10, -45, -90, -135, -170]
	for i in directions:
		var effect = ice_shard_effect.instance()
		get_parent().add_child(effect)
		effect.position = self.position
		effect.bullet_bhv.angle_in_degrees = i
		effect.bullet_bhv.speed = rand_range(20, 120)

func _on_DelayStartTimer_timeout() -> void:
	start_make()
