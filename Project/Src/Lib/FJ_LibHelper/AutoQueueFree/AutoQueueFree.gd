#Auto Queue Free
#Code by: First

#This node automatically take action when activated
#or as soon as the scene tree is entered.
#The main use of AutoQueueFree is to
#remove parent node as soon as the scene is entered.
#Useful if you're working on visual texts or objects that
#shows only in the editor and you do not wish it to be
#appeared in release builds.
#Also supports signal that connects to #this node to start 
#activation (usage is described below).

# Usage: Can be used anywhere. Place it within parent node.
#        To activate this node via signalling, connect to
#        this node and rename the method in node to
#        "_on_signal_call"

# Variables
#
# enum PresetQueueFreeAction
#       ┠╴DO_NOTHING : Don't do anything when activated.
#       ┠╴QUEUE_FREE : Queue free parent nodes, including
#       ┃              children and this node as well.
#       ┠╴FREE : Free all children and parent node. Note that
#       ┃        this only deletes the object from memory and
#       ┃        is not recommended unless you know what
#       ┃        you're doing. 
#       ┠╴RELEASE_CHILDREN : Moves all children outside the parent.
#       ┃                    This node and parent are unaffected.
#       ┠╴FREE_PARENT_RELEASE_CHILDREN : Moves all children outside
#       ┃                                the parent and free parent.
#       ┖╴FREE_CHILDREN_BUT_PARENT : This frees all children except
#                                   parent and this node.
#
# enum PresetQueueFreeAction
#       ┠╴AT_THE_START : Start activation immediately as soon as
#       ┃                _ready function is called.
#       ┖╴DISABLED : Don't do anything.
#
# export var one_time_use : Allow the use of this node once.
# export var allow_signal_connect_call : Determine whether this node
#                                        activates when a signal is
#                                        sent to this node.
# var is_activated : For use with @one_time_use

extends Node

class_name FJ_AutoQueueFree

enum PresetQueueFreeAction {
	DO_NOTHING,
	QUEUE_FREE,
	FREE,
	RELEASE_CHILDREN,
	FREE_PARENT_RELEASE_CHILDREN,
	FREE_CHILDREN_BUT_PARENT,
	CUSTOM
}

enum PresetActivationMode {
	AT_THE_START,
	DISABLED
}

export (PresetQueueFreeAction) var queue_free_action = PresetQueueFreeAction.QUEUE_FREE
export (PresetActivationMode) var activation_mode = PresetActivationMode.AT_THE_START
export (bool) var one_time_use = false
export (bool) var allow_signal_connect_call = true
export (Array, NodePath) var custom_queue_free_paths = []

var is_activated = false

func _ready():
	if activation_mode == PresetActivationMode.AT_THE_START:
		_start()

func _start():
	if one_time_use && is_activated:
		return
	
	#Queue free parent, including this node
	if queue_free_action == PresetQueueFreeAction.QUEUE_FREE:
		if !_is_parent_being_freed(true) && !_is_parent_viewport(true):
			get_parent().queue_free()
	#Free parent (unsafe), including this node
	if queue_free_action == PresetQueueFreeAction.FREE:
		if !_is_parent_being_freed(true) && !_is_parent_viewport(true):
			get_parent().free()
	#Release all children from parent outside parent without killing parent
	if queue_free_action == PresetQueueFreeAction.RELEASE_CHILDREN:
		for i in get_parent().get_children():
			if i != self:
				get_parent().call_deferred("remove_child", i)
				get_parent().get_parent().call_deferred("add_child", i)
	#Release all children from parent and queue_free parent, including this node
	if queue_free_action == PresetQueueFreeAction.FREE_PARENT_RELEASE_CHILDREN:
		for i in get_parent().get_children():
			if i != self:
				get_parent().call_deferred("remove_child", i)
				get_parent().get_parent().call_deferred("add_child", i)
		if !_is_parent_being_freed(true) && !_is_parent_viewport(true):
			get_parent().free()
	#Queue free all children from the parent, but not this node
	if queue_free_action == PresetQueueFreeAction.FREE_CHILDREN_BUT_PARENT:
		for i in get_parent().get_children():
			if i != self:
				if !i.is_queued_for_deletion():
					i.queue_free()
	#Queue free specified nodepaths
	if queue_free_action == PresetQueueFreeAction.CUSTOM:
		for i in custom_queue_free_paths:
			if !get_node(i).is_queued_for_deletion():
				get_node(i).queue_free()

#Checks
func _is_parent_being_freed(push_err : bool = false):
	var is_parent_being_freed = get_parent().is_queued_for_deletion()
	if push_err && is_parent_being_freed:
		push_error(str(self.name, ": Can't free due to parent node is already being freed."))
	
	return is_parent_being_freed
func _is_parent_viewport(push_err : bool = false):
	var is_parent_viewport = get_parent() is Viewport
	if push_err && is_parent_viewport:
		push_error(str(self.name, ": Freeing viewport core is not tolerated!"))
	
	return is_parent_viewport

#Use this if you want to connect signal and call on this func.
func _on_signal_call():
	if allow_signal_connect_call:
		_start()

#Start immediately without any hesitate
func direct_start():
	_start()
