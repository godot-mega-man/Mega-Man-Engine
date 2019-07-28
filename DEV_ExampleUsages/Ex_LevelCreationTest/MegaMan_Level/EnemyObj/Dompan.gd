extends EnemyCore

onready var pf_bhv = $PlatformBehavior
onready var sprite_ani = $SpriteMain/Sprite/SpriteAnimation

#Temp
var walk_direction : int
var is_hopping : bool = false
var is_about_to_hop = false

#Preloading scenes
var firework_effect = preload("res://DEV_ExampleUsages/Ex_LevelCreationTest/MegaMan_Level/Effects/FireworkEffect.tscn")

func _ready():
	turn_toward_player()

func turn_toward_player():
	if player == null:
		return
	
	if player.global_position.x < self.global_position.x:
		walk_direction = -1
	else:
		walk_direction = 1
	
	sprite_main.scale.x = -walk_direction

func _process(delta: float) -> void:
	if pf_bhv.on_air_time == 0 or is_hopping:
		pf_bhv.simulate_walk_right = walk_direction == 1
		pf_bhv.simulate_walk_left = walk_direction == -1
	
	if pf_bhv.on_air_time > 0:
		sprite_ani.play("Jumping")
	
	if not is_hopping && not pf_bhv.on_floor && not is_about_to_hop:
		pf_bhv.simulate_walk_right = false
		pf_bhv.simulate_walk_left = false

func _on_WalkTowardPlayerTimer_timeout() -> void:
	turn_toward_player()

func _on_PlatformerBehavior_by_wall() -> void:
	is_hopping = true
	is_about_to_hop = true
	sprite_ani.play("Hopping")

func jump():
	pf_bhv.simulate_jump = true
	is_about_to_hop = false

func _on_PlatformerBehavior_landed() -> void:
	pf_bhv.simulate_jump = false
	is_hopping = false
	sprite_ani.play("Walking")
	pf_bhv.is_just_by_wall = false

func _on_Dompan_slain(target) -> void:
	var effecta = firework_effect.instance()
	get_parent().add_child(effecta)
	effecta.position = self.position
