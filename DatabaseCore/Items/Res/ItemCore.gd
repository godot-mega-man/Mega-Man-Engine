extends Resource
class_name FJ_Res_Item

enum PresetItemRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

const ITEM_RARITY_COLOR = {
	PresetItemRarity.COMMON : NESColorPalette.WHITE4,
	PresetItemRarity.UNCOMMON : NESColorPalette.GREEN3,
	PresetItemRarity.RARE : NESColorPalette.LIGHTSTEELBLUE2,
	PresetItemRarity.EPIC : NESColorPalette.PURPLE2,
	PresetItemRarity.LEGENDARY : NESColorPalette.TOMATO2
}

export (String) var name : String = ""
export (String, MULTILINE) var description = ""
export (bool) var can_be_sold = true
export (int, 0, 1000000) var buy_cost : int = 100
export (float, 0, 1, 0.01) var sell_cost = 0.1 #Depends on buy cost.
export (PresetItemRarity) var rarity
export (Texture) var item_image