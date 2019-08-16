#PlatformBehavior2D
#Code by: First

# The Platform behavior applies the parent node of
# KinematicBody2d a side-view "jump and run" style
# movement. By default the Platform movement is
# controlled by the ui_left and ui_right keys and
# ui_up to jump.

# To set up custom controls, you
# can do so by setting export variables:
#    DEFAULT_CONTROL_LEFT = 'ui_left'
#    DEFAULT_CONTROL_RIGHT = 'ui_right'
#    DEFAULT_CONTROL_JUMP = 'ui_up'
# To set up automatic controls, you can set
# either one of these:
#    simulate_walk_left = true
#    simulate_walk_right = true
#    simulate_jump = true
# While any of the above is true (e.g. 
# simulate_walk_left), the parent node will
# move itself as if it was holding left button.

  ###Usage###
# Instance PlatformBehavior2D (from /Lib) or
# adding child node as
# User_PlatformBehavior2D (PlatformBehavior2D.gd)
# where you want a KinematicBody2D to have this
# behavior enabled. When attached, it's ready
# to be used!

#PROs:
# - No need to attach script and write it over
#   on every KinematicBody2D objects.
# - Can be used on every object that's
#   KinematicBody2D.
#CONs:
# - Quite complex to use.
# - The script is currently very complicated to 
#   understand if you plan to improve it.

extends Node

class_name FJ_PlatformBehavior2D

signal move_direction_changed(number)
signal move_and_collided(kinematic_collision)
signal landed
signal jumped
signal jumped_by_keypress
signal hit_ceiling
signal by_wall
signal warped_updown
signal warped_leftright
signal fell_into_pit
signal collided(kinematic_collision_2d)

enum MOVE_TYPE_PRESET {
	MOVE_AND_SLIDE,
	MOVE_AND_COLLIDE
}

export(MOVE_TYPE_PRESET) var move_type = 0
export(Vector2) var GRAVITY_VEC = Vector2(0, 900.0) # pixels/second/second
export(float) var WALK_SPEED = 250 # pixels/sec
export(float) var JUMP_SPEED = 360
export(float) var SIDING_CHANGE_SPEED = 10
export(float) var VELOCITY_X_DAMPING = 0.1
export(float) var MAX_FALL_SPEED = 600

export var FLOOR_NORMAL = Vector2(0, -1)

export(bool) var INITIAL_STATE = true
export(bool) var CONTROL_ENABLE = true
export(bool) var IS_PREVENT_OUTSIDE_SCREEN = true
export(int) var PREVENT_OUTSIDE_SCREEN_OFFSET = 12 #Won't work if WARPS_LEFT_RIGHT_SIDE is on.
export(bool) var USE_TIP_TOE_MOVEMENT = false
export(float) var MAX_TIP_TOE_FRAME = 7

export(String) var DEFAULT_CONTROL_LEFT = 'game_left'
export(String) var DEFAULT_CONTROL_RIGHT = 'game_right'
export(String) var DEFAULT_CONTROL_JUMP = 'game_jump'

#Below only works if the level is defined to work with this.
export (bool) var WARPS_AROUND_UP_DOWN = true
export (bool) var WARPS_LEFT_RIGHT_SIDE = true
export (Vector2) var WARP_OFFSET := Vector2(8, 24)

#Define NodePath.
#If not defined, some features will not be used.
export(NodePath) var level_path

#lookup nodes
onready var audio_manager = get_node_or_null("/root/AudioManager")
onready var level = get_node_or_null("/root/Level")
onready var level_view_container := get_node_or_null("/root/Level/ViewContainer") as LevelViewContainer

onready var parent : Node = get_parent()

#Temp variables

#Current velocity reported after move_and_slide or
#move_and_collided on parent node is called.
#Note that if you want to get velocity report before
#move_and_slide or move_and_collide is called, use
#velocity_before_move_and_slide instead.
var velocity := Vector2()

var on_air_time : float = 0
var jumping = false
var midair_jump_left = 0
var prev_jump_pressed = false
var is_just_landed = true
var is_just_hit_ceiling = false
var is_just_by_wall
#Simulate control where it can be toggled.
#While on, the object will keep moving until toggled off.
var simulate_walk_left = false
var simulate_walk_right = false
var simulate_jump = false
var walk_left = false #Init... once
var walk_right = false #Init... once
var on_floor = true
var on_ceiling = false
var on_wall = false
var jump = false #Init... once
var move_direction : int #-1 = moving left, 1 = moving right, 0 = still.
var left_right_key_press_time : float = 0

#Velocity before move_and_slide or move_and_collide is called.
#Useful if you want to get velocity report when landed, hit by wall,
#or hit by ceiling.
#Note that the variable name was changed. So you might want to use
#get_velocity_before_move_and_slide() instead.
var velocity_before_move_and_slide := Vector2() setget ,get_velocity_before_move_and_slide

func _ready():
	if !is_validate():
		return

func _physics_process(delta):
	#Won't work if parent node is not KinematicBody2D.
	if !is_validate():
		return
	parent = parent as KinematicBody2D
	
	#Check for initial state
	if !INITIAL_STATE:
		return
	
	move_direction = 0
	
	### MOVEMENT ###
	
	# Apply gravity
	velocity += delta * GRAVITY_VEC
	
	# Either Move and slide or Move and collide
	if move_type == MOVE_TYPE_PRESET.MOVE_AND_SLIDE:
		#TIP TOE: IF ON, I WILL HANDLE THIS.
		if USE_TIP_TOE_MOVEMENT:
			if left_right_key_press_time < MAX_TIP_TOE_FRAME and on_floor:
				if left_right_key_press_time > 2:
					velocity.x = 0
				else:
					if walk_left:
						velocity.x = -60
					if walk_right:
						velocity.x = 60
				
		
		#Set velocity before move and slide. For more info,
		#please see its variable.
		set_velocity_before_move_and_slide(velocity)
		
		velocity = custom_move_and_slide(velocity, FLOOR_NORMAL)
	elif move_type == MOVE_TYPE_PRESET.MOVE_AND_COLLIDE:
		var kinematic_collision = parent.move_and_collide(GRAVITY_VEC * delta)
		if kinematic_collision != null:
			emit_signal("move_and_collided", kinematic_collision)
	# Detect if we are on floor - only works if called *after* move_and_slide
	on_floor = parent.is_on_floor()
	on_ceiling = parent.is_on_ceiling()
	on_wall = parent.is_on_wall()
	
	#Adds up on-air time while not on floor
	if not on_floor:
		on_air_time += delta
	else:
		on_air_time = 0
	
	#Checks
	if velocity.y > MAX_FALL_SPEED: #Limits fall speeds
		velocity.y = MAX_FALL_SPEED
	if on_floor: #Emit signal on landed once.
		if !is_just_landed:
			is_just_landed = true
			emit_signal("landed")
	else:
		is_just_landed = false
	if on_ceiling: #Emit signal on ceiling once, reset velocity y
		if !is_just_hit_ceiling:
			is_just_hit_ceiling = true
			emit_signal("hit_ceiling")
		
		velocity.y = 0
	else:
		is_just_hit_ceiling = false
	if on_wall: #Emit signal on wall once.
		if !is_just_by_wall:
			is_just_by_wall = true
			emit_signal("by_wall")
	else:
		is_just_by_wall = false
	
	### CONTROL ###
	
	# Horizontal movement
	var target_speed = 0
	walk_left = (Input.is_action_pressed(DEFAULT_CONTROL_LEFT) && CONTROL_ENABLE) || simulate_walk_left
	walk_right = (Input.is_action_pressed(DEFAULT_CONTROL_RIGHT) && CONTROL_ENABLE) || simulate_walk_right
	jump = (Input.is_action_pressed(DEFAULT_CONTROL_JUMP) && CONTROL_ENABLE) || simulate_jump
	if walk_left:
		target_speed -= 1
	if walk_right:
		target_speed += 1

	target_speed *= WALK_SPEED
	velocity.x = lerp(velocity.x, target_speed, VELOCITY_X_DAMPING)

	# Jumping by keypress
	if jump:
		jump_start()
	
	#Prevents outside screen of the game.level
	if level_view_container != null :
		if IS_PREVENT_OUTSIDE_SCREEN && !level_view_container.WARPS_OBJECTS_LEFT_RIGHT_SIDE:
			parent.global_position.x = clamp(parent.global_position.x, level_view_container.CAMERA_LIMIT_LEFT, level_view_container.CAMERA_LIMIT_RIGHT)
	
	#Move Direction
	#DEV NOTE: Removed check if on_floor.
	if velocity.x < -SIDING_CHANGE_SPEED:
		move_direction = -1
	if velocity.x > SIDING_CHANGE_SPEED:
		move_direction = 1
	
	check_warp_around_up_down()
	check_warp_around_left_right()
	check_falling_into_pit()
	check_left_right_key_press_time(delta) #Resetter


#The same as calling parent: move_and_slidec
#This also emit signal the collision's information.
#Sets velocity after move_and_slide() on parent node is called.
func custom_move_and_slide(custom_velocity, custom_floor_normal) -> Vector2:
	if parent is KinematicBody2D:
		var vel = parent.move_and_slide(custom_velocity, custom_floor_normal)
		
		if parent.get_slide_count() > 0:
			for i in parent.get_slide_count():
				emit_signal("collided", parent.get_slide_collision(i))
		
		return vel
	
	return Vector2()

#Controls
func jump_start(var check_condition = true) -> void:
	if check_condition:
		if !on_floor:
			return
		else:
			emit_signal("jumped")
			#Emit signal that the jump is done by keypress.
			if Input.is_action_pressed(DEFAULT_CONTROL_JUMP) && CONTROL_ENABLE:
				emit_signal("jumped_by_keypress")
	
	velocity.y = -JUMP_SPEED

func check_warp_around_up_down():
	if level_view_container == null:
		return
	
	if level_view_container.WARPS_OBJECTS_AROUND_UP_DOWN && WARPS_AROUND_UP_DOWN:
		var limit_bottom = level_view_container.CAMERA_LIMIT_BOTTOM + WARP_OFFSET.y
		var limit_top = level_view_container.CAMERA_LIMIT_TOP - WARP_OFFSET.y
		
		if parent.position.y > limit_bottom:
			parent.position.y = limit_top
			emit_signal("warped_updown")

func check_warp_around_left_right():
	if level_view_container == null:
		return
	
	if level_view_container.WARPS_OBJECTS_LEFT_RIGHT_SIDE && WARPS_LEFT_RIGHT_SIDE:
		#If player is at the edge of the screen at either side,
		#force player to warp around left-right.
		if parent.position.x < level_view_container.CAMERA_LIMIT_LEFT - WARP_OFFSET.x:
			parent.position.x = level_view_container.CAMERA_LIMIT_RIGHT + WARP_OFFSET.x
		if parent.position.x > level_view_container.CAMERA_LIMIT_RIGHT + WARP_OFFSET.x:
			parent.position.x = level_view_container.CAMERA_LIMIT_LEFT - WARP_OFFSET.x
		emit_signal("warped_leftright")

func check_falling_into_pit():
	if level_view_container == null:
		return
	
	if level_view_container.WARPS_OBJECTS_AROUND_UP_DOWN:
		return
	
	var limit_bottom = level_view_container.CAMERA_LIMIT_BOTTOM + WARP_OFFSET.y
	if parent.position.y > limit_bottom:
		emit_signal("fell_into_pit")

func check_left_right_key_press_time(delta):
	if not(walk_left or walk_right): #If not currently doing either one of these
		left_right_key_press_time = 0
	else:
		left_right_key_press_time += 60 * delta

#Check if this node will work. Return false if not.
#An optional parameter can be passed to print for specific errors.
func is_validate(var print_errors : bool = false) -> bool:
	var is_all_valid = true
	
	if !parent is KinematicBody2D:
		printerr(
			str(
				self.name,
				": ",
				parent,
				" is not a KinematicBody2D. So this node will neither work nor have effects." 
			)
		)
		is_all_valid = false
	
	return is_all_valid



##########################
### Getter/Setter
##########################

func set_velocity_before_move_and_slide(val : Vector2) -> void:
	velocity_before_move_and_slide = val

func get_velocity_before_move_and_slide() -> Vector2:
	return velocity_before_move_and_slide