#Level Brightness Modifier
#Code by: First
#References: Mega Man 4 - Bright Man Stage

#Level Brightness Modifier is the level extension that modifies
#current level's brightness through auto-load scripts.
#Note that this is an object enabler managed by auto-loaded script.
#You should not touch the code or anything here besides export variables.

#Instance this scene to a root node of '/Level', then specify
#node paths and you're done!

#Example use of this object:
#res://DEV_ExampleUsages/Ex_LevelCreationTest/MegaMan_Level/Level.tscn

extends Node
class_name LevelBrightnessModifier

########################
### Export Variables ###
########################

export (Array, NodePath) var modify_paths


###################
### CHILD NODES ###
###################

#Revert timer. How long the brightness will be back to what it was.
#For ex: If brightness is set to make area plunge into darkness,
#the timer will then start to restore brightness overtime when timeout.
#Setting to zero will not start the timer which makes it permanent.
onready var _duration_timer = $DurationTimer
onready var _anim = $AnimationPlayer

#################
### TEMP VARS ###
#################

var current_state : bool #The current state of brightness that we need
							#to use it when the delay timer is up.
var prev_brightness_state : bool = true

##############################################################
### Method Functions .. DO NOT TOUCH OR CALL THESE BELOW!! ###
##############################################################

func start(var lv_brightness_type : bool, var duration : float = 0.0):
	current_state = lv_brightness_type
	
	#Start timer if it's duration is not zero (Zero is forever).
	if duration > 0:
		_duration_timer.start(duration)
	else:
		_duration_timer.stop()
	
	#Start right away
	start_right_away()

func update_brightness(var alpha_modulate_value : float):
	for i in modify_paths:
		var node = get_node(i)
		assert(node is CanvasItem)
		node.set_modulate(Color(node.modulate.r, node.modulate.g, node.modulate.b, alpha_modulate_value))

#Time out, revert back to what it was...
func _on_RevertTimer_timeout() -> void:
	play_brightness_animation(!current_state)
	prev_brightness_state = current_state

#WORK ON, check conditions
func start_right_away() -> void:
	#If current state is the same as newly state, do nothing.
	#Otherwise, play animation.
	if prev_brightness_state == current_state:
		play_brightness_animation(current_state)
	prev_brightness_state = !current_state

func play_brightness_animation(var brighten_type : bool):
	if brighten_type == true:
		_anim.play("BlackOut")
	if brighten_type == false:
		_anim.play("Brightening")
