# BrightnessShader
# Written by: First

extends Node

class_name BrightnessShader

"""
	Add option for a parent node of CanvasItem to change the brightness.
	It uses a shader resource of Brightness.shader
	
	Note that this will not make shader work on the editor.
"""

#-------------------------------------------------
#      Classes
#-------------------------------------------------

#-------------------------------------------------
#      Signals
#-------------------------------------------------

#-------------------------------------------------
#      Constants
#-------------------------------------------------

const BRIGHTNESS_SHADER = preload("res://Lib/FJ_LibHelper/BrightnessShader/BrightnessShader.shader")

#-------------------------------------------------
#      Properties
#-------------------------------------------------

export (float) var brightness = 0 setget set_brightness

onready var s_material : ShaderMaterial

#-------------------------------------------------
#      Notifications
#-------------------------------------------------

func _ready():
	_init_shader_material()
	update_current_parent_brightness()

#-------------------------------------------------
#      Virtual Methods
#-------------------------------------------------

#-------------------------------------------------
#      Override Methods
#-------------------------------------------------

#-------------------------------------------------
#      Public Methods
#-------------------------------------------------

func update_current_parent_brightness():
	if s_material == null:
		return
	
	s_material.set_shader_param("bright_amount", brightness)

#-------------------------------------------------
#      Connections
#-------------------------------------------------

#-------------------------------------------------
#      Private Methods
#-------------------------------------------------

func _init_shader_material() -> void:
	var p = get_parent()
	
	if p is CanvasItem:
		s_material = ShaderMaterial.new()
		s_material.set_shader(BRIGHTNESS_SHADER)
		
		p.set_material(s_material)

#-------------------------------------------------
#      Setters & Getters
#-------------------------------------------------

func set_brightness(val : float) -> void:
	brightness = val
	update_current_parent_brightness()
