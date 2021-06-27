class_name FJ_ButtonEffect extends Control


enum EffectModePreset{
	HORIZONTAL_OPEN,
	VERTICAL_OPEN,
	EXPAND_FROM_CENTER,
}


onready var color_rect = $ColorRect

onready var animation_player = $AnimationPlayer


export (float) var tween = 0

export (float) var tween_reverse = 0


var origin_position : Vector2

var effect_mode = EffectModePreset.HORIZONTAL_OPEN


func _ready() -> void:
	origin_position = color_rect.rect_position


func _process(delta: float) -> void:
	if effect_mode == EffectModePreset.HORIZONTAL_OPEN:
		color_rect.rect_size.x = rect_size.x * tween
		color_rect.rect_size.y = rect_size.y
		
		color_rect.rect_position.x = origin_position.x * tween_reverse
		color_rect.rect_position.y = 0
	
	if effect_mode == EffectModePreset.VERTICAL_OPEN:
		color_rect.rect_size.x = rect_size.x
		color_rect.rect_size.y = rect_size.y * tween
		
		color_rect.rect_position.x = 0
		color_rect.rect_position.y = origin_position.y * tween_reverse
	
	if effect_mode == EffectModePreset.EXPAND_FROM_CENTER:
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
