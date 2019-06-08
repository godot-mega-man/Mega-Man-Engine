extends "res://Misc/InventoryCore/Items/Items.gd"
class_name Equipment

enum Equipment_slot {
	WEAPON,
	AMMUNITION,
	ARMOR,
	ACCESSORY
}

export (Equipment_slot) var slot = Equipment_slot.WEAPON
export (int, 1, 7) var level = 1
export (int) var power = 10
export (float) var attack_cooldown = 0.5
export (int) var armor = 0
export (bool) var upgradable = true