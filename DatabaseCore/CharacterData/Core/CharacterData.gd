# CharacterData
# Code by: First

extends Resource

class_name CharacterData

export (Texture) var character_spritesheet
export (NESColorPalette.NesColor) var primary_color
export (NESColorPalette.NesColor) var secondary_color
export (NESColorPalette.NesColor) var outline_color = NESColorPalette.NesColor.BLACK1
export (NESColorPalette.NesColor) var outline_color_charge1 = NESColorPalette.NesColor.PINK1
export (NESColorPalette.NesColor) var outline_color_charge2 = NESColorPalette.NesColor.PINK2
export (NESColorPalette.NesColor) var outline_color_charge3 = NESColorPalette.NesColor.PINK3