# TODO: Refactor so that it works only for MegaMan-type characters
# CharacterData
#
# Data for MegaMan-type characters

class_name CharacterData extends Resource


export (Texture) var character_spritesheet

export (NESColorPalette.NesColor) var primary_color

export (NESColorPalette.NesColor) var secondary_color

export (NESColorPalette.NesColor) var outline_color

export (NESColorPalette.NesColor) var outline_color_charge1

export (NESColorPalette.NesColor) var outline_color_charge2

export (NESColorPalette.NesColor) var outline_color_charge3
