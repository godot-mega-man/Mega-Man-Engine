extends Resource
class_name Items

enum PresetItemCategory {
	MATERIAL,
	CONSUMABLE,
	KEY_ITEM,
	EQUIPMENT,
	UNCATEGORIZED
}

enum PresetItemRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

const ITEM_RARITY_COLOR = {
	PresetItemRarity.COMMON : Color("ffffff"),   #White
	PresetItemRarity.UNCOMMON : Color("59db55"), #Green
	PresetItemRarity.RARE : Color("0059fb"),     #Blue
	PresetItemRarity.EPIC : Color("db00cf"),     #Purple
	PresetItemRarity.LEGENDARY : Color("fb3800") #Orange
}

export (PresetItemCategory) var category
export (String) var name : String = ""
export (String, MULTILINE) var description = ""
export (int, 1, 1000000) var value : int = 100
export (bool) var can_sell = true
export (PresetItemRarity) var rarity
export (String, FILE, "*.png") var item_image = "res://Misc/InventoryCore/Items/"