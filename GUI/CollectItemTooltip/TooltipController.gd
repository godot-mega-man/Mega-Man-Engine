extends Control

#Child nodes
onready var ttb_container = $TtbContainer #TooltipBoxContainer, if ya don't know.

#Preloading
var tooltip_box = preload("res://GUI/CollectItemTooltip/TooltipBox.tscn")

#Constant variables
export var MAX_SIZE = 7

#Temp
var current_item_name : String = ""
var current_quantity : int = 0
var last_node_within_ttbc #ttbc = TooltipBoxContainer

#Upon collecting an item: Be it anything collectible,
#This will create a tooltip box inside ttb_container (TooltipBoxContainer)
#and let it play slide animation.
func add_collected_item_tooltip(new_header_label : String, new_quan_label : int = 0, new_icon_texture = null, new_rarity = 0) -> void:
	var can_stack : bool = false
	#Check if the last collected item can stack the quantity with the same item.
	if ttb_container.get_child_count() > 0:
		if new_header_label == current_item_name:
			#Check if last node within TooltipBoxContainer exists
			#and allows stacking
			if not get_node_or_null(last_node_within_ttbc) == null:
				if get_node(last_node_within_ttbc).is_time_out == false:
					can_stack = true
	
	if can_stack:
		#Increase quantity counter
		current_quantity += new_quan_label
		get_node(last_node_within_ttbc).set_quantity_label(current_quantity)
		get_node(last_node_within_ttbc).refresh_time()
	else:
		#When there is not enough space for the new one (max size limit),
		#all of the oldest box will be instantly removed until there's
		#enough space.
		if ttb_container.get_child_count() >= MAX_SIZE:
			for i in ttb_container.get_child_count() - (MAX_SIZE - 1):
				ttb_container.get_child(i).queue_free()
		
		var inst_tooltip_box = tooltip_box.instance()
		ttb_container.add_child(inst_tooltip_box)
		inst_tooltip_box.initiate(new_header_label, new_quan_label, new_icon_texture, new_rarity)
		last_node_within_ttbc = inst_tooltip_box.get_path()
		
		#Set current
		current_item_name = new_header_label
		current_quantity = new_quan_label