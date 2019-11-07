extends Node

#Persistent variables
var saved_player_position : Vector2
var saved_view_name : String
var current_checkpoint_position : Vector2
var current_checkpoint_target_scene : String setget set_current_checkpoint_target_scene, get_current_checkpoint_target_scene
var current_checkpoint_priority : int = 0

#Getter/setter
func get_current_checkpoint_target_scene() -> String:
	return current_checkpoint_target_scene
func set_current_checkpoint_target_scene(var new_value : String) -> void:
	current_checkpoint_target_scene = new_value

#Update player's checkpoint posiition
func update_checkpoint_position(var new_position : Vector2, var scene : String, var new_view : String, var ignore_priority : bool = false, var new_priority_value : int = 0) -> void:
	var is_updated : bool = false #Identify that checkpoint will be updated or not.
	
	#Start update checkpoint.
	#If priority is equals or higher than previous checkpoint, then
	#the checkpoint will be updated.
	#However, you can bypass priority value by setting
	#@param 'ignore_priority' to true.
	#New priority for current checkpoint will also be updated.
	if new_priority_value >= current_checkpoint_priority or ignore_priority:
		current_checkpoint_position = new_position
		current_checkpoint_target_scene = scene
		current_checkpoint_priority = new_priority_value
		saved_view_name = new_view
		is_updated = true
	
	if is_updated:
		print(self.name, "(update_checkpoint_position): Checkpoint updated. New position is ", new_position, ", scene: ", scene)
	else:
		print(self.name, "(update_checkpoint_position): Checkpoint contacted by player but not updated.")

#Uses when player dies.
func override_saved_player_position():
	saved_player_position = current_checkpoint_position

func has_checkpoint():
	return current_checkpoint_position != Vector2(0, 0)

func clear_checkpoint() -> void:
	saved_view_name = ""
	current_checkpoint_position = Vector2(0, 0)
	current_checkpoint_target_scene = ""
	current_checkpoint_priority = 0
