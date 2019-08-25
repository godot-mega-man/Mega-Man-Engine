#Palette Sprite Core
#Code by: First

"""
	Palette Sprite copies the parent's sprite behavior to support
	NES color palettes.
	Example of image patterns can be found here:
	res://Assets/Sprites/Characters/MegaMan.png
"""

tool #Used to create built-in resource
extends Node2D
class_name PaletteSprite

#####################
### Constants
#####################

const SPRITE_PALETTE_DATA_RES_NAME = "ColorPalData"

#####################
### Properties
#####################

export (int) var primary_color_frame_add = 0
export (int) var secondary_color_frame_add = 0
export (int) var outline_color_frame_add = 0
export (int) var current_palette_state = 0 setget set_current_palette_state
export (Array, Resource) var palette_states : Array setget set_palette_states

onready var primary_sprite := $Primary as Sprite
onready var second_sprite := $Secondary as Sprite #Strangely. It's too late to fix typo..
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
	update_color_palettes()

func _process(delta):
	if Engine.is_editor_hint():
		return
	
	var parent = get_parent()
	
	if parent is Sprite:
		primary_sprite.frame = parent.frame + primary_color_frame_add
		second_sprite.frame = parent.frame + secondary_color_frame_add
		outline_sprite.frame = parent.frame + outline_color_frame_add
	
	set_subnode_textures() #Set every frame

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

#Update current palette colors using current palette state.
#Automatically called when current_palette_state is set.
func update_color_palettes() -> void:
	if palette_states.empty():
		return
	
	primary_sprite.modulate = Color((palette_states[current_palette_state] as SpriteColorPaletteData).primary_color)
	second_sprite.modulate = Color((palette_states[current_palette_state] as SpriteColorPaletteData).secondary_color)
	outline_sprite.modulate = Color((palette_states[current_palette_state] as SpriteColorPaletteData).outline_color)

#Get resource: SpriteColorPaletteData
#Pass -1 (default value) to get SpriteColorPaletteData by current_palette_state 
#An error is returned if index of palette_states is out of bound.
func get_sprite_color_palette_data(index : int = -1) -> SpriteColorPaletteData:
	if palette_states == null:
		return null
	if palette_states.empty():
		return null
	
	if not index == -1:
		return palette_states[index]
	else:
		if index > palette_states.size() - 1:
			return palette_states[palette_states.size() - 1]
		return palette_states[current_palette_state]

#######################
### Setters / getters
#######################

func set_current_palette_state(val : int) -> void:
	if val <= 0:
		val = 0
	
	current_palette_state = val
	
	update_color_palettes()

func set_palette_states(val : Array) -> void:
	palette_states = val
	
	#Insert color palette data set at the last element
	#of an array.
	if val == null:
		return
	if val.empty():
		return
	if val.back() == null:
		val.pop_back()
		
		#Create a new resource
		var sprite_color_pal_data = SpriteColorPaletteData.new()
		sprite_color_pal_data.set_name(SPRITE_PALETTE_DATA_RES_NAME)
		
		#Assign a newly created resource at the end of array.
		val.push_back(sprite_color_pal_data)