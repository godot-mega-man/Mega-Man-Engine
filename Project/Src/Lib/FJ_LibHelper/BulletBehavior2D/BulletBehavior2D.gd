# BulletBehavior2D

tool # Used for configuration warnings
extends Node

class_name FJ_BulletBehavior

"""
	The Bullet behavior simply moves parent object forwards at
	an angle. However, it provides extra options like gravity
	and angle in degrees that allow it to also be used.
	Like the name suggests it is ideal for projectiles like
	bullets, but it is also useful for automatically 
	controlling other types of objects like enemies
	which move forwards continuously.
	
	This will work on any parent node having 'position' property.
	Place it under parent node and start configuring.
"""

#-------------------------------------------------
#      Classes
#-------------------------------------------------

#-------------------------------------------------
#      Signals
#-------------------------------------------------

signal distance_travelled_reached

signal stopped_moving 

# Reports that a kinematicbody2D collided with something.
# Only emitted if root node is a Kinematicbody2D and you set
# `kbody_move_and_collide` to on.
signal kbody_collided(kinematic_collision_2d)

#-------------------------------------------------
#      Constants
#-------------------------------------------------

# The process how the object moves from a chosen behavior:
#
# - Idle: Update once per frame.
#
# - Physics: Update and sync with physics.
enum PROCESS_TYPE {
	IDLE,
	PHYSICS
}

#-------------------------------------------------
#      Properties
#-------------------------------------------------

# The node you want to have this behavior applied.
export (NodePath) var root_node = "./.." setget set_root_node, get_root_node

# If false, the behavior is in disabled state and won't do anything.
export (bool) var active = true

# The process how the object moves from a chosen behavior:
#
# - Idle: Update once per frame.
#
# - Physics: Update and sync with physics.
export(PROCESS_TYPE) var process_mode = 1

# The bullet's initial speed, in pixels per second.
export (float) var speed = 120

# When on, min and max speed will be used.
export (bool) var speed_limit = false

# Minimum speed in pixel per second.
export (float) var min_speed = 0

# Maximum speed in pixel per second.
export (float) var max_speed = 150

# The rate of acceleration for the bullet, in pixels per second per second.
# Zero will keep a constant speed, positive values accelerate, and negative
# values decelerate until a stop (the object will not go in to reverse).
export (float) var acceleration = 0

# The force of gravity, which causes acceleration downwards, in
# pixels per second per second. Zero disables gravity which is useful for
# top-down games. Positive values cause a parabolic path as the bullet
# is bullet down by gravity.
export (float) var gravity = 0

# The maximum force of gravity. If the gravity of the root node is
# above zero, max fall speed will be positive (as what it was).
# And if the gravity of the root node is below zero, max fall speed
# will be used as negative value.
export (float, 0, 9000, 0.1) var max_fall_speed = 900

# 0 = Right, 90 = Down, 180 = Left, 270 = Up
#
# 0 = Right, -90 = Up, -180 = Left, -270 = Down
export (float) var angle_in_degrees = 0.0

# Move and collide for a KinematicBody2D node. This is only for
# KinematicBody2D and will stop if it collides, which emits signal
# `kbody_collided(kinematic_collision_2d)` when that happens.
export (bool) var kbody_move_and_collide

# If true, the speed will never go below zero.
export (bool) var allow_negative_speed = false

# Signal on distance travelled by pixels.
# Specified travel value will be used to emit a signal.
export (float) var signal_on_distance_travelled = 500


# Temp variables
var _init_position := Vector2()
var current_acceleration : float = 0
var current_gravity : float = 0
var current_distance_traveled : float = 0
var vec_angle : Vector2
var velocity : Vector2



#-------------------------------------------------
#      Notifications
#-------------------------------------------------

func _get_configuration_warning() -> String:
	var warning : String = ""
	
	if not "position" in get_node(root_node):
		warning += "This will work only on root node having 'position' property. "
		warning += "Consider picking root node on Node2D or Control."
	
	return warning

func _ready() -> void:
	if Engine.is_editor_hint(): # We want this to works only in-game.
		return
	
	_init_position = get_node(root_node).get_position()

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): # We want this to works only in-game.
		return
	
	if process_mode == PROCESS_TYPE.IDLE:
		_do_process(delta)
		_check_and_emit_signals()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): # We want this to works only in-game.
		return
	
	if process_mode == PROCESS_TYPE.PHYSICS:
		_do_process(delta)
		_check_and_emit_signals()




#-------------------------------------------------
#      Public Methods
#-------------------------------------------------

#-------------------------------------------------
#      Private Methods
#-------------------------------------------------

func _do_process(delta: float) -> void:
	var _fetched_root_node = get_node(root_node)
	if not active:
		return
	
	# Set normalized vector2's angle
	vec_angle = Vector2(cos(deg2rad(angle_in_degrees)), sin(deg2rad(angle_in_degrees)))
	
	# Set movement speed in pixels per second
	var movement = speed + current_acceleration
	# Clamp movement between limits (if on)
	if speed_limit == true:
		movement = clamp(movement, min_speed, max_speed)
	if movement < 0 and not allow_negative_speed:
		movement = 0
	velocity = vec_angle * movement * delta
	
	# Apply gravity
	# Limits current gravity first, then apply to _gravity.
	if current_gravity > 0:
		if current_gravity > max_fall_speed:
			current_gravity = max_fall_speed
	else:
		if current_gravity < -max_fall_speed:
			current_gravity = -max_fall_speed
	var _gravity = Vector2(0, current_gravity) * delta
	
	# Remember current position
	var prev_position = _fetched_root_node.position
	
	# Start movement.
	# If the root node is a KinematicBody2D, we will call
	# move_and_collide (if kbody_move_and_collide is enabled).
	# Otherwise, we will just change its position instead.
	if _fetched_root_node is KinematicBody2D and kbody_move_and_collide == true:
		var kinematic_col = _fetched_root_node.move_and_collide(velocity + _gravity)
		
		if kinematic_col != null:
			emit_signal("kbody_collided", kinematic_col)
	else:
		_fetched_root_node.position += velocity + _gravity
	
	# Increment values
	current_acceleration += acceleration * delta
	current_gravity += gravity * delta
	current_distance_traveled += prev_position.distance_to(_fetched_root_node.position)

# Check all emit-able signals. If there's one that can be emitted,
# start one.
var _is_signal_distance_travelled_reached_emitted : bool = false
var _is_signal_stopped_moving_emitted : bool = false
func _check_and_emit_signals():
	if (current_distance_traveled >= signal_on_distance_travelled and !_is_signal_distance_travelled_reached_emitted):
		emit_signal("distance_travelled_reached")
		_is_signal_distance_travelled_reached_emitted = true
	else:
		_is_signal_distance_travelled_reached_emitted = false
	
	if (velocity == Vector2(0, 0) and !_is_signal_stopped_moving_emitted):
		emit_signal("stopped_moving")
		_is_signal_stopped_moving_emitted = true
	else:
		_is_signal_stopped_moving_emitted = false



#-------------------------------------------------
#      Setters & Getters
#-------------------------------------------------

func set_root_node(val) -> void:
	root_node = val
	emit_signal("script_changed")

func get_root_node() -> NodePath:
	return root_node
