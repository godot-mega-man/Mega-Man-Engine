extends Node

signal leveled_up

#Player
var current_hp
var restore_hp_on_load = true
var is_died = false

var current_level = 1
var experience_point = 0 setget set_experience_point
var experience_point_next

#Game Data
var experience_point_next_table : Array = [] #Init though _ready() function
var max_level = experience_point_next_table.size()

#Temp
var exp_lost : int = 0

#Getter/Setter
func set_experience_point(new_value):
	experience_point = new_value
	check_for_level_up()

func _ready() -> void:
	init_experience_targets()
	update_exp_next()

func init_experience_targets() -> void:
	experience_point_next_table = get_experience_targets_data()

func update_exp_next():
	experience_point_next = experience_point_next_table[current_level - 1]

func get_experience_targets_data() -> Array:
	var total_level = 100
	var exp_base = 120
	var exp_increment = 100
	var multiplier = 1.1
	var multiplier_increment = 0.5
	
	var result = []
	
	#Calculate exp formula though total levels.
	for i in total_level:
		var next_up = exp_base + ((exp_increment * i) * (multiplier + (multiplier_increment * i)))
		result.append(next_up)
	
	return result

#Check whether player is level up.
#When current experience points reaches the target,
#player will level up. Current experience points will also
#subtracted by previous next-value.
func check_for_level_up():
	#If player levels up... YAY! JUST CONGRATS THOSE!
	if experience_point >= experience_point_next: #Reached target exp
		level_up()

func level_up(free_level_up : bool = false):
	#Free level up means no experience points are subtracted.
	#This can happen in many cases.
	#Ex: Reward from completing epic tasks, in-app purchases, etc.
	if !free_level_up:
		experience_point -= experience_point_next #Subtract by next-value.
	
	current_level += 1
	update_exp_next()
	
	#Play level up sound
	FJ_AudioManager.sfx_ui_level_up.play()
	
	emit_signal("leveled_up")

#This will cause player to lose current exp.
#Only use in case the player is being dead (death penalty).
func decrease_exp_as_penalty_by_ratio(var lost_ratio_0_to_1 : float) -> void:
	#Start calculating amount of exp lost
	var total_lost_exp = (experience_point_next * lost_ratio_0_to_1)
	total_lost_exp = ceil(total_lost_exp) #Round up
	if experience_point - total_lost_exp < 0:
		total_lost_exp = experience_point
	
	#dECREASE!
	decrease_exp(total_lost_exp)
	#Save how many coins have lost
	exp_lost = total_lost_exp

#This func is just like subtracting exp.
#But this prevents negative exp.
func decrease_exp(var value : int):
	experience_point -= value
	if experience_point < 0:
		experience_point = 0

func clean_up_lost_exp():
	exp_lost = 0