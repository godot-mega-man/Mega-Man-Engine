extends Node
class_name GlobalVariables

#SAVES ENEMY'S EXP CYCLE AND COIN CYCLE EVERYTIME THE SCENE IS CHANGED.
#THIS WILL SAVE LEVEL NAME PACKED WITH ENEMY NAMES.
#EX: Dict = {level_name{Enemy1: 5, Enemy2: 2}, another_level_name{}}
var enemies_saved_exp_cycle = {}
var enemies_saved_coin_cycle = {}
#END OF SAVES ENEMY'S EXP CYCLE AND COIN CYCLE 
var enemies_perma_death_level = {} #LIST OF PERMANENT DEAD ENEMIES WITHIN LEVEL

#INVENTORY!
#Item can be stacked while equipment items will be kept
#as seperate item with its stats information.
var inventory_items : Array = []