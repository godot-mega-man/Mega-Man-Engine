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
const SIGNAL_PALETTE_STATES_SUB_RES_CHANGED = "_on_PaletteSprite_changed"

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
	var parent = get_parent()
	
	if parent is Sprite:
		$Primary.frame = parent.frame + primary_color_frame_add
		$Secondary.frame = parent.frame + secondary_color_frame_add
		$Outline.frame = parent.frame + outline_color_frame_add
	
	set_subnode_textures() #Set every frame
	update_color_palettes()

#####################
### Public Methods
#####################

func set_subnode_centered():
	var parent = get_parent()
	
	if parent is Sprite:
		$Primary.centered = parent.centered
		$Secondary.centered = parent.centered
		$Outline.centered = parent.centered

func set_subnode_textures():
	var parent = get_parent()
	
	if parent is Sprite:
		$Primary.texture = parent.texture
		$Secondary.texture = parent.texture
		$Outline.texture = parent.texture

func set_subnode_hframes():
	var parent = get_parent()
	
	if parent is Sprite:
		$Primary.hframes = parent.hframes
		$Secondary.hframes = parent.hframes
		$Outline.hframes = parent.hframes

func set_subnode_vframes():
	var parent = get_parent()
	
	if parent is Sprite:
		$Primary.vframes = parent.vframes
		$Secondary.vframes = parent.vframes
		$Outline.vframes = parent.vframes

func set_subnode_offsets():
	var parent = get_parent()
	
	if parent is Sprite:
		$Primary.offset = parent.offset
		$Secondary.offset = parent.offset
		$Outline.offset = parent.offset

#Update current palette colors using current palette state.
#Automatically called when current_palette_state is set.
func update_color_palettes() -> void:
	if palette_states.empty():
		return
	
	var sprite_color_pal_data = palette_states[current_palette_state] as SpriteColorPaletteData
	
	if sprite_color_pal_data != null:
		$Primary.modulate = Color(sprite_color_pal_data.primary_color)
		$Secondary.modulate = Color(sprite_color_pal_data.secondary_color)
		$Outline.modulate = Color(sprite_color_pal_data.outline_color)

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
	update_color_palettes()
	
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
		
		#Connect _script_changed to this node so the sprites
		#can update the palette sprites when it updates.
		sprite_color_pal_data.connect("changed", self, SIGNAL_PALETTE_STATES_SUB_RES_CHANGED)
		
		#Assign a newly created resource at the end of array.
		val.push_back(sprite_color_pal_data)
		

func _on_PaletteSprite_changed():
	update_color_palettes()
