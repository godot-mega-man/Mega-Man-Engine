#Sprite Cycling
#Code by: First

#Sprite Cycling turns all children within the parent node
#to draw sprites in forward order one frame and
#backward order the next when two sprites are
#overlapping each other.

# USE CASES:
#   There are two items with similiar image size
#   that are overlapping at the same spot, which
#   makes either item A or B can barely be seen.
#   How about if we swap both item A and B
#   cycling back and forth so some part of their
#   sprites can be seen? Wouldn't be that great
#   to not confusing player with item A is
#   being hidden by item B? This is called
#   "Faking Transparency".

# USAGE: Can be used anywhere. Place it within the parent node.
# Example:
#
# Root
# ┖╴Node2D
#   ┠╴Iterable
#   ┠╴Sprite          <- Affects by iterable.
#   ┠╴Kinematic2d     <- Affects by iterable.
#   ┠╴Label           <- No effect.
#   ┖╴Node2D          <- Affects by iterable.  
#     ┠╴Label          <- No effect, but affected to parent.
#     ┖╴Sprite         <- No effect, but affected to parent.
#
# COMPATIBILITY: Node2D

#tool #Remove this line if you do not wish this script to work in the editor.
extends Node
class_name Iterable

export(bool) var enabled = true
export(Array, int) var frames_per_iterate = [0, 1] #Array length should be power of n. e.g. 1, 2, 4, or 8, ..
												#this will wait for n frames before iterate starts.
												#there is a pointer that will move to the next of an array
												#once iteration is done in said frame.
var z_swapping = 0 #Increment every frames. Resets on reaching frames_per_iterate[pointer]
var pointer = 0 #Pointer on array of frames_per_iterate
var swap_mode = 0 #0 = no iterate, other than 0 = iterate

var nes_slow_down : bool = false
const MAX_LOOPABLE = 10
var current_loop = 0


func _ready() -> void:
	nes_slow_down = GameSettings.gameplay.nes_slowdown


func _process(delta : float) -> void:
	if !enabled:
		return
	if GameSettings.gameplay.sprite_flicker:
		_do_sprite_swap_process()
	if GameSettings.gameplay.nes_slowdown:
		_do_nes_slowdown_process()
	


func get_iterable_nodes():
	var nodes = get_parent().get_children()
	
	if GameHUD.player_vital_bar.visible:
		nodes.append(GameHUD.player_vital_node2d)
	if GameHUD.player_weapon_bar.visible:
		nodes.append(GameHUD.player_weapon_node2d)
	if GameHUD.boss_vital_bar.visible:
		nodes.append(GameHUD.boss_vital_node2d)
	
	return nodes


func _do_sprite_swap_process():
	var children = get_iterable_nodes()
	var drawable_children : Array = []
	var it = children.size()
	var sprite_drawn = 0
	current_loop = 0
	
	for i in children:
		if(swap_mode == 0):
			it += 1
		else:
			it -= 1
		if "z_index" in i: #Safe call
			i.z_index = it
	
	if(z_swapping >= frames_per_iterate[pointer]):
		z_swapping = 0
		_modify_swap_mode()
		pointer = _move_pointer(pointer, frames_per_iterate)
	else:
		z_swapping += 1


func _do_nes_slowdown_process():
	var children = get_iterable_nodes()
	
	if children != null:
		if swap_mode == 0:
			for i in children:
				if i is Node2D or i is Control:
					if current_loop < MAX_LOOPABLE:
						i.visible = true
					else:
						i.visible = false
					current_loop += 1
		else:
			for i in range(children.size() -1, -1, -1):
				if children[i] is Node2D or children[i] is Control:
					if current_loop < MAX_LOOPABLE:
						children[i].visible = true
					else:
						children[i].visible = false
					current_loop += 1
	
	if current_loop >= MAX_LOOPABLE * 1.8:
		Engine.set_time_scale(0.5)
	else:
		Engine.set_time_scale(1)
	


func _modify_swap_mode():
	swap_mode = int(!bool(swap_mode))


func _move_pointer(var which_pointer : int, var which_array : Array):
	if which_pointer >= which_array.size() - 1:
		which_pointer = 0
	else:
		which_pointer += 1
	
	return which_pointer
