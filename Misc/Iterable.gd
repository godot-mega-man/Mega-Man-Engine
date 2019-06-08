'''Z-position Cycle Swapping'''

#CONCEPT: NINTENDO ENTERTAINMENT SYSTEM GAMES
#CODE BY: FIRST

#WHEN BOTH SPRITES ARE OVERLAPPING EACH OTHER, THEY WILL SWAP
#THEIR Z-POSITION, CYCLING BACK AND FORTH. THIS IS EXTREMELY
#USEFUL IN CASE AN OBJECT IS HIDDEN BEHIND ANOTHER OBJECT WHERE
#ITS SOME PART OF THE SPRITE CAN'T BE ENTIRELY SEEN.

#YOU SHALL NOT MODIFY Z-INDEX DIRECTLY WHILE AN OBJECT IS
#BEING ITERATE.

# USAGE: Can be used anywhere. Place it within parent node.
# Example:
#
# Root
# ┖╴Node2D
#   ┠╴Iterable
#   ┠╴Sprite          <- Affects by iterable.
#   ┠╴Kinematic2d     <- Affects by iterable.
#   ┠╴Label           <- No effect.
#   ┖╴Node2D          <- Affects by iterable.  
#     ┠╴Label          <- No effect, but affected by parent.
#     ┖╴Sprite         <- No effect, but affected by parent.
#
# COMPATIBILITY: Node2D, 

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
	var children = get_parent().get_children()
	var it = children.size()
	
	if !enabled:
		return
	
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