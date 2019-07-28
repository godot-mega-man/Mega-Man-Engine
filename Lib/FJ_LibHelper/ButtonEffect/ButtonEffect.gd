extends Control

class_name FJ_ButtonEffect

#Effect modes preset
enum effect_mode_preset{
	HORIZONTAL_OPEN,
	VERTICAL_OPEN,
	EXPAND_FROM_CENTER,
}

#Child nodes
onready var color_rect = $ColorRect
onready var animation_player = $AnimationPlayer

export (float) var tween = 0
export (float) var tween_reverse = 0

var origin_position : Vector2
var effect_mode = 0 #Effect mode initial

func _ready() -> void:
	#Set origin position
	origin_position = color_rect.rect_position

#Set rect
func _process(delta: float) -> void:
	if effect_mode == effect_mode_preset.HORIZONTAL_OPEN:
		color_rect.rect_size.x = rect_size.x * tween
		color_rect.rect_size.y = rect_size.y
		
		color_rect.rect_position.x = origin_position.x * tween_reverse
		color_rect.rect_position.y = 0
	
	if effect_mode == effect_mode_preset.VERTICAL_OPEN:
		color_rect.rect_size.x = rect_size.x
		color_rect.rect_size.y = rect_size.y * tween
		
		color_rect.rect_position.x = 0
		color_rect.rect_position.y = origin_position.y * tween_reverse
	
	if effect_mode == effect_mode_preset.EXPAND_FROM_CENTER:
		color_rect.rect_size.x = rect_size.x * tween
		color_rect.rect_size.y = rect_size.y * tween
		
		color_rect.rect_position.x = origin_position.x * tween_reverse
		color_rect.rect_position.y = origin_position.y * tween_reverse

func set_effect_color(var what_color : Color) -> void:
	color_rect.color = what_color

func set_animation_duration(var speed : float) -> void:
	animation_player.playback_speed = speed

func set_effect_type(var type) -> void: 
	effect_mode = type