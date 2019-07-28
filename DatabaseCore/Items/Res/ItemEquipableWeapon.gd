extends FJ_Res_ItemEquipable
class_name FJ_Res_ItemEquipableWeapon

#Attack Type. Used in character's casting animation.
enum AttackType {
	Melee,
	Ranged,
	Magic
}

enum AttackMode {
	Manual,
	Auto
}

export (PackedScene) var attack_projectile
export (AttackType) var attack_type
export (AttackMode) var attack_mode = 0.1
export (float) var attack_cooldown = 0.1