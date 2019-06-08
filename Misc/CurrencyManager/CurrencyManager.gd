extends Node

#Persistent data
var game_coin = 0
var game_diamond = 0
#Temp data
var coin_lost : int = 0 #Save as future referencing

#Lookup nodes
onready var global_var = get_node("/root/GlobalVariables")

#This will cause player to lost total coins.
#Only use in case the player is being dead (death penalty).
func decrease_coins_as_penalty_by_ratio(var lost_ratio_0_to_1 : float) -> void:
	var lost_variance = 0.10 #In ratio. e.g. 0.25 = 25%
	var lost_min = 3
	var lost_max = 2000
	
	#Start calculating amount of coins lost
	var total_lost_coin = (game_coin * lost_ratio_0_to_1)
	total_lost_coin *= 1 + rand_range(-lost_variance, lost_variance) #Vary total lost coin
	total_lost_coin = clamp(total_lost_coin, 0, lost_max) #Clamp between min and max
	total_lost_coin = ceil(total_lost_coin) #Round up
	
	#dECREASE!
	decrease_coin(total_lost_coin, true)
	#Save how many coins have lost
	coin_lost = total_lost_coin

#Useful for shopping and item checks.
func is_sufficient_by_amount(var amount_to_check : int) -> bool:
	return amount_to_check >= game_coin

#Decrease coin by amount.
#If decreasing amount will causes the game_coin to go,
#negative, the method will return false. Otherwise,
#return true.
func decrease_coin(var amount : int, var ignore_negative : bool = false) -> bool:
	var can_decrease : bool
	
	if is_sufficient_by_amount(amount):
		can_decrease = true
	else:
		can_decrease = false
	
	if can_decrease or ignore_negative:
		game_coin -= amount
		if game_coin < 0:
			game_coin = 0
	
	return can_decrease or ignore_negative

func clean_up_lost_coin():
	coin_lost = 0