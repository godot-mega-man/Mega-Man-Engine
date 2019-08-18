extends Node
class_name FJ_Game_SkillsDamage

export (FJ_Enum_DamageType.DamageType) var damage_type
export (float) var damage_value = 255
export (bool) var critical_hits = true
export (float, 0, 1) var damage_variance = 0.2