extends EnemyCore

export var offset = 0 
export (float) var dist_increase_per_sec_init = 25
export (float) var dist_increase_per_sec_fired = 240

onready var sine_bhv_h = $SineBehaviorHori
onready var sine_bhv_v = $SineBehaviorVert
onready var sprite_ani = $SpriteMain/Ani
onready var palette_sprite = $SpriteMain/Sprite/PaletteSprite

var is_fired = false

func _ready():
	sine_bhv_h._current_cycle += offset
	sine_bhv_v._current_cycle += offset

func _process(delta: float) -> void:
	if not is_fired:
		var speed = dist_increase_per_sec_init * delta
		sine_bhv_h.magnitude += speed
		sine_bhv_v.magnitude += speed
	else:
		var speed = dist_increase_per_sec_fired * delta
		sine_bhv_h.magnitude += speed
		sine_bhv_v.magnitude += speed

func _on_LaunchTime_timeout() -> void:
	FJ_AudioManager.sfx_combat_large_explosion_mm3.play()
	is_fired = true
	sprite_ani.play("Large")
