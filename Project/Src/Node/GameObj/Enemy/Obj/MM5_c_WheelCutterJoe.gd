extends EnemyCore

export (NESColorPalette.NesColor) var primary_color
export (NESColorPalette.NesColor) var secondary_color
export (NESColorPalette.NesColor) var outline_color

onready var spawn_wheel_pos = $SpriteMain/SpawnWheelPos
onready var palette_sprite = $SpriteMain/Sprite/PaletteSprite
onready var rest_timer = $RestTimer
onready var launch_timer = $LaunchTimer
onready var sprite_ani = $SpriteMain/Ani

var wheel_cutter = preload("res://Src/Node/GameObj/Enemy/Obj/MM10_WheelCutter.tscn")
var my_wheel


func _ready():
	if Difficulty.difficulty == Difficulty.DIFF_NEWCOMER:
		current_hp = 2
		rest_timer.wait_time = 1.4
	if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
		current_hp = 5
	
	palette_sprite.primary_sprite.modulate = Color(primary_color)
	palette_sprite.second_sprite.modulate = Color(secondary_color)
	palette_sprite.outline_sprite.modulate = Color(outline_color)
	
	turn_toward_player()
	spawn_wheel_cutter()

#Just change animation...
func _on_LaunchTimer_timeout():
	rest_timer.start()
	sprite_ani.play("Fire")
	if is_instance_valid(my_wheel) and my_wheel != null:
		my_wheel.release()
	my_wheel = null
	
	Audio.play_sfx("wheel_cutter")

#Spawn wheel cutter..
#Set delay timer for wheel cutter
func _on_RestTimer_timeout():
	turn_toward_player()
	spawn_wheel_cutter()
	
	launch_timer.start()
	sprite_ani.play("Producing")


func spawn_wheel_cutter():
	var wheel_enemy_obj = wheel_cutter.instance()
	wheel_enemy_obj.initial_state = false
	get_parent().add_child(wheel_enemy_obj)
	wheel_enemy_obj.set_move_direction(-sprite_main.scale.x)
	wheel_enemy_obj.global_position = spawn_wheel_pos.global_position
	my_wheel = wheel_enemy_obj


func _on_WheelCutterJoe_taking_damage(value, target, player_proj_source) -> void:
	if player_proj_source.projectile_name == "ring":
		event_damage = 0.5


func _on_WheelCutterJoe_tree_exiting() -> void:
	if is_instance_valid(my_wheel) and my_wheel != null:
		my_wheel.pickups_drop_enabled = false
		my_wheel.death_sound = EnemyCore.dead_sfx.NONE
		my_wheel.die()
