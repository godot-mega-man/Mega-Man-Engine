#Projectile Reflector
#Code by First

#ProjectileReflector holds information to tell parent node of- 
#Area2D that its reflectable by either Player's projectile or
#enemy's projectile

#Used in: Enemy (res://Entities/Enemy/Obj/Enemy.tscn)
#         and Player(res://Entities/Player/Player.tscn)
#         which is a shield area.
#Within: Area2D
#Example usage can be found in res://DEV_ExampleUsages/

extends Node

class_name ProjectileReflector

signal reflected

export(bool) var enabled = true
export(float, 0, 1) var reflect_chance = 1

# List of projectiles where they will not get reflected
export (Array, String) var projectile_names_exception

#Return true if it's reflectable.
#False if not reflectable.
func do_reflect(projectile_name : String) -> bool:
	var is_success = can_reflect(projectile_name)
	
	if is_success:
		emit_signal("reflected")
	
	return is_success

func can_reflect(projectile_name : String) -> bool:
	if not enabled:
		return false
	if not rand_range(0.0, 1.0) < reflect_chance:
		return false
	if not projectile_name.empty() and projectile_names_exception.has(projectile_name):
		return false
	
	return true
