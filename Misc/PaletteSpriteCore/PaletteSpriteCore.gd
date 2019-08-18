#Palette Sprite Core
#Code by: First

"""
	Palette Sprite copies the parent's sprite behavior to support
	NES color palettes.
	Example of image patterns can be found here:
	res://Assets_ReleaseExcluded/Sprites/Characters/MegaMan.png
"""

extends Node2D
class_name PaletteSprite

#####################
### Properties
#####################

export (int) var primary_color_frame_add = 0
export (int) var secondary_color_frame_add = 0
export (int) var outline_color_frame_add = 0

onready var primary_sprite := $Primary as Sprite
onready var second_sprite := $Secondary as Sprite
onready var outline_sprite := $Outline as Sprite



#####################
### Notifications
#####################

#Loads texture at the start
func _ready():
	set_subnode_centered()
	set_subnode_hframes()
	set_subnode_vframes()
	set_subnode_offsets()

func _process(delta):
	var parent = get_parent()
	
	if parent is Sprite:
		primary_sprite.frame = parent.frame + primary_color_frame_add
		second_sprite.frame = parent.frame + secondary_color_frame_add
		outline_sprite.frame = parent.frame + outline_color_frame_add
	
	set_subnode_textures() #Set every frame but once if it's not the same.

#####################
### Public Methods
#####################

func set_subnode_centered():
	var parent = get_parent()
	
	if parent is Sprite:
		primary_sprite.centered = parent.centered
		second_sprite.centered = parent.centered
		outline_sprite.centered = parent.centered

func set_subnode_textures():
	var parent = get_parent()
	
	if parent is Sprite:
		primary_sprite.texture = parent.texture
		second_sprite.texture = parent.texture
		outline_sprite.texture = parent.texture

func set_subnode_hframes():
	var parent = get_parent()
	
	if parent is Sprite:
		primary_sprite.hframes = parent.hframes
		second_sprite.hframes = parent.hframes
		outline_sprite.hframes = parent.hframes

func set_subnode_vframes():
	var parent = get_parent()
	
	if parent is Sprite:
		primary_sprite.vframes = parent.vframes
		second_sprite.vframes = parent.vframes
		outline_sprite.vframes = parent.vframes

func set_subnode_offsets():
	var parent = get_parent()
	
	if parent is Sprite:
		primary_sprite.offset = parent.offset
		second_sprite.offset = parent.offset
		outline_sprite.offset = parent.offset