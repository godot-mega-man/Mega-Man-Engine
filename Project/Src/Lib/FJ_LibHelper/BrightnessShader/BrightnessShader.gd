# BrightnessShader
#
# Adds option for a parent node of CanvasItem to change the brightness at
# runtime. It uses a shader resource of Brightness.shader in order for this
# to work.

class_name BrightnessShader extends Node


const BRIGHTNESS_SHADER = preload("res://Src/Lib/FJ_LibHelper/BrightnessShader/BrightnessShader.shader")

export (float) var brightness = 0 setget set_brightness

onready var s_material : ShaderMaterial


func _ready():
	_init_shader_material()
	update_current_parent_brightness()


func set_brightness(val : float) -> void:
	brightness = val
	update_current_parent_brightness()


func update_current_parent_brightness():
	if s_material == null:
		return
	
	s_material.set_shader_param("bright_amount", brightness)


func _init_shader_material() -> void:
	var p = get_parent()
	
	if p is CanvasItem:
		s_material = ShaderMaterial.new()
		s_material.set_shader(BRIGHTNESS_SHADER)
		
		p.set_material(s_material)

