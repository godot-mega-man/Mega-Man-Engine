extends EnemyCore

export (NESColorPalette.NesColor) var primary_color = NESColorPalette.NesColor.WHITE1
export (NESColorPalette.NesColor) var secondary_color = NESColorPalette.NesColor.WHITE4
export (NESColorPalette.NesColor) var outline_color = NESColorPalette.NesColor.BLACK1

onready var spawn_wheel_pos = $SpriteMain/SpawnWheelPos
onready var palette_sprite = $SpriteMain/Sprite/PaletteSprite
onready var rest_timer = $RestTimer
onready var launch_timer = $LaunchTimer
onready var sprite_ani = $SpriteMain/Ani

var wheel_cutter = preload("res://Entities/Enemy/Obj/MM10_WheelCutter.tscn")

func _ready():
	palette_sprite.primary_sprite.modulate = Color(primary_color)
	palette_sprite.second_sprite.modulate = Color(secondary_color)
	palette_sprite.outline_sprite.modulate = Color(outline_color)
	
	turn_toward_player()
	_spawn_wheel_cutter()

#Just change animation...
func _on_LaunchTimer_timeout():
	rest_timer.start()
	sprite_ani.play("Fire")

#Spawn wheel cutter..
#Set delay timer for wheel cutter
func _on_RestTimer_timeout():
	turn_toward_player()
	_spawn_wheel_cutter()
	
	launch_timer.start()
	sprite_ani.play("Producing")
	
	FJ_AudioManager.sfx_combat_wheel_cutter.play()


func _spawn_wheel_cutter():
	var wheel_enemy_obj = wheel_cutter.instance()
	wheel_enemy_obj.initial_state = false
	get_parent().add_child(wheel_enemy_obj)
	wheel_enemy_obj.set_move_direction(-sprite_main.scale.x)
	wheel_enemy_obj.global_position = spawn_wheel_pos.global_position
