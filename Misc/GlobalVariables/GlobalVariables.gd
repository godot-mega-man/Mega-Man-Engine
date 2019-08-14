extends Node
class_name GlobalVariables

#INVENTORY!
#Item can be stacked while equipment items will be kept
#as seperate item with its stats information.
var inventory_items : Array = []

var saved_game_events : Dictionary = {}

var saved_dead_enemies : Array

var current_view : String = ""

var current_player_primary_color := NESColorPalette.TORQUOISE3
var current_player_secondary_color := NESColorPalette.TORQUOISE2
var current_player_outline_color := NESColorPalette.BLACK1

#Obsolete!
func add_to_dead_enemies(obj : DeadEnemyInfo):
	saved_dead_enemies.push_back(obj)
