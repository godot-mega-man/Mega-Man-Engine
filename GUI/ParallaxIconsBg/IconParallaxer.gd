extends Control

export (Vector2) var scroll_speed = Vector2(60, 30)
export (float) var expand_margin_horizontal = 128
export (float) var expand_margin_vertical = 128
export (bool) var auto_start = false

#Child nodes
onready var texture_rect = $TextureRect

#Temp scroll
var current_scroll = Vector2(0, 0)
var origin_position : Vector2
var is_parallax_active = false

func _ready() -> void:
	#Set expand margin
	set_expand_margin()
	
	#After expand margin has been "SET"!, Set origin position
	origin_position = texture_rect.rect_position
	
	#Start_process_at_start
	set_parallax_active(auto_start)

func _process(delta: float) -> void:
	#Scroll!
	current_scroll.x += scroll_speed.x * delta
	current_scroll.y += scroll_speed.y * delta
	
	#Check whether scroll exceeds limit
	#Reset X-pos
	if current_scroll.x < -expand_margin_horizontal:
		current_scroll.x += expand_margin_horizontal
	if current_scroll.x > expand_margin_horizontal:
		current_scroll.x -= expand_margin_horizontal
	#Reset Y-pos
	if current_scroll.y < -expand_margin_vertical:
		current_scroll.y += expand_margin_vertical
	if current_scroll.y > expand_margin_vertical:
		current_scroll.y -= expand_margin_vertical
	
	texture_rect.rect_position = origin_position + current_scroll

func set_expand_margin():
	texture_rect.margin_left = -expand_margin_horizontal
	texture_rect.margin_top = -expand_margin_vertical
	texture_rect.margin_right = expand_margin_horizontal
	texture_rect.margin_bottom = expand_margin_vertical

func set_parallax_active(var set : bool):
	is_parallax_active = set
	set_process(set)

func is_active():
	return is_parallax_active

func reset_scroll_to_initial():
	current_scroll = Vector2(0, 0)