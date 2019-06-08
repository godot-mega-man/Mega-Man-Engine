extends "res://Misc/InventoryCore/Items/Items.gd"
class_name Consumable

enum Consumable_type {
	HEAL_HP,
	HEAL_MP,
	HEAL_BOTH_HP_MP,
	BUFF,
	TRIGGER_EVENT
}

export (Consumable_type) var type = Consumable_type.HEAL_HP
export (int) var health_restored = 0
export (int) var mana_restored = 0

export (float, 1.0, 16.0) var buffed_atk_ratio = 0
export (int, 0, 9999) var buffed_atk_value = 0
export (float, 1.0, 16.0) var buffed_def_ratio = 0
export (int, 0, 9999) var buffed_def_value = 0
export (float, 1.0, 16.0) var buffed_hp_ratio = 0
export (int, 0, 9999) var buffed_hp_value = 0