# Auto Queue Free
#
# This node automatically take action when activated or as soon as the scene
# tree is entered. The main use of AutoQueueFree is to remove parent node
# when initialized. Useful if you're working on visual texts or objects that
# require to show either only in the editor or in release builds. Also 
# supports signal that connects to this node to start activation.

class_name FJ_AutoQueueFree extends Node


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


# Start immediately without any hesitate
func direct_start():
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

