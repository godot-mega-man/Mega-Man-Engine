extends Node
class_name ChainDestroyController

signal destroy_process_finished

export(NodePath) var tile_map_to_modify
export(bool) var one_shot = true

#Child nodes
onready var destroy_delay_timer = $DestoryDelayTimer

#Temp
var is_active = false
var pointer = 1

func set_chain_destroy_active():
	#Terminate itself when all children has been destroyed
	if pointer > get_child_count():
		destroy_delay_timer.stop()
	else:
		#Check if first node is ChainDestroyerArea.
		if !get_child(pointer) is ChainDestroyerArea:
			push_error('Start failed. Do not put any unrelated children inside ChainDestroyController! Expected node: AreaChainDestroyer')
		else:
			#Get current children and call it to destroy blocks.
			get_child(pointer)._destroy_blocks()
			
			#Get next children's delay timer.
			#If next children is exist (more than 1 excluding Timer node), then call.
			#Otherwise, the destroy process will be stopped.
			if pointer + 1 < get_child_count():
				var delay_time = get_child(pointer + 1).destroy_delay
				destroy_delay_timer.start(delay_time)
				pointer += 1
				if delay_time == 0:
					set_chain_destroy_active()
			else:
				destroy_delay_timer.stop()
				if !one_shot: #If one-shot is disabled, it can be activated again.
					is_active = false
					pointer = 1
				
				emit_signal("destroy_process_finished")
	

func _on_DestoryDelayTimer_timeout() -> void:
	#When called, tiles will get destroyed.
	#And then child node (AreaChainDestroyer) will be freed by itself.
	if get_child(1) is ChainDestroyerArea:
		set_chain_destroy_active()
	else:
		push_error('Destroy failed. Do not put any unrelated children inside ChainDestroyController! Expected node: AreaChainDestroyer')

#When manually connected, 
#this will automatically start active chaining.
func _on_AreaNotifier_entered_area() -> void:
	activate_chain() 
func _on_Enemy_dead() -> void:
	activate_chain() 

func activate_chain() -> void:
	if !is_active:
		is_active = true
		set_chain_destroy_active()
