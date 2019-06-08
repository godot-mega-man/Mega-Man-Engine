extends Node

class_name PlatformerBehavior

signal move_direction_changed(number)
signal move_and_collided(kinematic_collision)
signal landed
signal hit_ceiling

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
export(int) var MAX_SLIDES = 4

export(bool) var INITIAL_STATE = true
export(bool) var CONTROL_ENABLE = true
export(bool) var IS_PREVENT_OUTSIDE_SCREEN = true
export(int) var PREVENT_OUTSIDE_SCREEN_OFFSET = 12

export(String) var DEFAULT_CONTROL_LEFT = 'game_left'
export(String) var DEFAULT_CONTROL_RIGHT = 'game_right'
export(String) var DEFAULT_CONTROL_JUMP = 'game_jump'

#Define NodePath.
#If not defined, some features will not be used.
export(NodePath) var level_path

#lookup nodes
onready var audio_manager = get_node_or_null("/root/AudioManager")
onready var level = get_node_or_null("/root/Level")

onready var parent = get_parent()

#Temp variables
var velocity = Vector2()
var on_air_time : float = 0
var jumping = false
var midair_jump_left = 0
var prev_jump_pressed = false
var is_just_landed = true
var is_just_hit_ceiling = true
#Simulate control where it can be toggled.
#While on, the object will keep moving until toggled off.
var simulate_walk_left = false
var simulate_walk_right = false
var simulate_jump = false
var walk_left = false #Init... once
var walk_right = false #Init... once
var on_floor = true
var on_ceiling = false
var jump = false #Init... once
var move_direction : int #-1 = moving left, 1 = moving right, 0 = still.

func _ready():
	if !is_validate():
		return

func _physics_process(delta):
	#Won't work if parent node is not KinematicBody2D.
	if !is_validate():
		return
	else:
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
		velocity = parent.move_and_slide(velocity, FLOOR_NORMAL, false, 10)
	elif move_type == MOVE_TYPE_PRESET.MOVE_AND_COLLIDE:
		var kinematic_collision = parent.move_and_collide(GRAVITY_VEC)
		if kinematic_collision != null:
			emit_signal("move_and_collided", kinematic_collision)
	# Detect if we are on floor - only works if called *after* move_and_slide
	on_floor = parent.is_on_floor()
	on_ceiling = parent.is_on_ceiling()
	
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
	if IS_PREVENT_OUTSIDE_SCREEN && level != null:
		parent.global_position.x = clamp(parent.global_position.x, level.CAMERA_LIMIT_LEFT, level.CAMERA_LIMIT_RIGHT)
	
	#Move Direction
	#DEV NOTE: Removed check if on_floor.
	if velocity.x < -SIDING_CHANGE_SPEED:
		move_direction = -1
	if velocity.x > SIDING_CHANGE_SPEED:
		move_direction = 1

#Controls
func jump_start(var check_condition = true) -> void:
	if check_condition:
		if !on_floor:
			return
	velocity.y = -JUMP_SPEED

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