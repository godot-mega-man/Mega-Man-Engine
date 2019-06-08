extends Node
class_name ItemData

var item_res : Resource setget set_item_res, get_item_res
var item_quantity : int = 1 setget set_item_quantity, get_item_quantity

func get_item_res() -> Resource:
	return item_res
func set_item_res(new_value) -> void:
	item_res = new_value
func get_item_quantity() -> int:
	return item_quantity
func set_item_quantity(new_value) -> void:
	item_quantity = new_value

#Increase quantity by amount
func add_item_quantity(var amount : int) -> void:
	item_quantity += amount

#Decrease quantity by amount.
#Note that this is unsafe method as the value can go negative.
#However, you can clamp negative value back to zero.
func decrease_item_quantity(var amount : int, var clamp_back_to_zero = true) -> void:
	item_quantity -= amount
	if item_quantity < 0:
		item_quantity = 0

#Decrease quantity by amount.
#This method is safer, if the value goes negative,
#the item quantity won't changed.
#Useful for using consumable items or crafting items.
func safe_decrease_item_quantity(var amount : int) -> bool:
	var can_decrease : bool
	
	#If amount goes negative, return false.
	if amount > item_quantity:
		can_decrease = false
	else: #Otherwise, decrease quantity by amount (safe).
		item_quantity -= amount
		can_decrease = true
	
	return can_decrease

#Check if item remaining is sufficient for 'amount'.
#This will not modify item's quantity, only checks.
func sufficient_check(var amount : int) -> bool:
	if amount > item_quantity: #Insufficient
		return false
	
	return true #Sufficient