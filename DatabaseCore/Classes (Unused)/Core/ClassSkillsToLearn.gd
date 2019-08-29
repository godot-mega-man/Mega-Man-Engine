tool
extends Node
class_name FJ_Game_ClassSkillsToLearn

export (Array, Resource) var skills : Array setget _set_skills

func _set_skills(var val : Array) -> void:
	if val != null and val.size() > 0:
		if val.back() == null:
			val.pop_back()
			val.append(FJ_Game_ClassSkillsToLearnPacks.new())
	skills = val