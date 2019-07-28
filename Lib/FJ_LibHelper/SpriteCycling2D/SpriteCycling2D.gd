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
export(Array, int) var frames_per_iterate = [0] #Array length should be power of n. e.g. 1, 2, 4, or 8, ..
												#this will wait for n frames before iterate starts.
												#there is a pointer that will move to the next of an array
												#once iteration is done in said frame.
var z_swapping = 0 #Increment every frames. Resets on reaching frames_per_iterate[pointer]
var pointer = 0 #Pointer on array of frames_per_iterate
var swap_mode = 0 #0 = no iterate, other than 0 = iterate

func _process(delta : float) -> void:
	if !GameSettings.gameplay.sprite_flicker:
		return
	if !enabled:
		return
	
	var children = get_parent().get_children()
	var it = children.size()
	
	for i in children:
		if(swap_mode == 0):
			it += 1
		else:
			it -= 1
		if "z_index" in i: #Safe call
			i.z_index = it
	
	if(z_swapping >= frames_per_iterate[pointer]):
		z_swapping = 0
		modify_swap_mode()
		pointer = move_pointer(pointer, frames_per_iterate)
	else:
		z_swapping += 1

func modify_swap_mode():
	swap_mode = int(!bool(swap_mode))

func move_pointer(var which_pointer : int, var which_array : Array):
	if which_pointer >= which_array.size() - 1:
		which_pointer = 0
	else:
		which_pointer += 1
	
	return which_pointer