extends Node

#Lookup nodes
onready var global_var = get_node("/root/GlobalVariables")

#Temp variables
var item_update_found_index : int = -1
#Item data as object
var item_data

#Adding item.
#Method: Check if item exists.
#If exists, update item's quantity.
#Otherwise, insert new entry to array.
#TO DECREASE ITEMS, DO NOT ADD NEGATIVE QUANTITY! USE decrease_item() instead.
func add_item(var item_res : Resource, var quantity : int = 1):
	item_data = ItemData.new()
	encapsulate_item_data(item_res, quantity)
	
	if is_item_in_inventory(item_data) and !is_item_type_of_equipment(item_res):
		update_add_item_quantity_in_inventory(quantity)
	else:
		insert_new_item_entry_to_inventory(item_data, quantity)

#Check if specified item is exists
#Return index of the item if found. Otherwise, return -1
#This will also update current temp_index
func is_item_in_inventory(var item_data_to_check : ItemData) -> bool:
	var i : int = 0 #Iterating index

	for j in (global_var.inventory_items as Array):
		#Check for resource path.
		#If found, update temp_index and return true
		if item_data_to_check.get_item_res().get_path() == j.get_item_res().get_path():
			item_update_found_index = i
			return true
		i += 1
	
	return false

#This will update quantity in current inventory.
#Note that this will cause an unexpected error if item is not found.
func update_add_item_quantity_in_inventory(var quantity : int) -> void:
	(global_var.inventory_items as Array)[item_update_found_index].add_item_quantity(quantity)

func update_decrease_item_quantity_in_inventory(var quantity : int) -> void:
	(global_var.inventory_items as Array)[item_update_found_index].decrease_item_quantity(quantity)

func encapsulate_item_data(var res : Resource, var new_quantity : int):
	item_data.set_item_res(res)
	item_data.set_item_quantity(new_quantity)

func insert_new_item_entry_to_inventory(new_item_data : ItemData, var quantity : int):
	(global_var.inventory_items as Array).push_front(new_item_data)

func decrease_item(var item_res : Resource, var quantity : int = 1) -> bool:
	item_data = ItemData.new()
	encapsulate_item_data(item_res, quantity)
	
	if is_item_in_inventory(item_data):
		update_decrease_item_quantity_in_inventory(quantity)
		return true #Decrease success
	else:
		return false #Fail to decrease

func is_item_type_of_equipment(var item_res : Resource):
	if item_res is FJ_Res_ItemEquipable:
		return true
	
	return false