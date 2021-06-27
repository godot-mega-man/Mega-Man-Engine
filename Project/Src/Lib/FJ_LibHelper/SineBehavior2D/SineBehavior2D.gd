# Sine Behavior
#
# The Sine behavior can adjust an object's properties 
# (like its position, size or angle) back and forth 
# according to an oscillating sine wave. This can be used
# to create interesting visual effects. Despite the name,
# alternative wave functions like 'Triangle' can also be
# selected to create different effects.

class_name FJ_SineBehavior2D extends Node


enum MOVEMENT_TYPE {
	HORIZONTAL,
	VERTICAL,
	ANGLE,
	OPACITY,
}

enum PROCESS_TYPE {
	IDLE,
	PHYSICS
}

# Enable behaviour at the beginning of the layout.
# If No, the behavior will have no effect until the Set active action is used.
export(bool) var active_on_start = true setget set_active, is_active

# The process how the object moves from a chosen behavior:
# - Idle: Update once per frame.
# - Physics: Update and sync with physics.
export(PROCESS_TYPE) var process_mode = 0 setget set_process_mode

export(MOVEMENT_TYPE) var movement = 0

# The wave function used to calculate the movement.
export(Curve) var wave : Curve setget set_wave

# The duration, in seconds, of one complete back-and-forth cycle.
export(float) var period = 2 setget set_period

# A random number of seconds added to the period for each instance. This can
# help vary the appearance when a lot of instances are using the Sine behavior.
export(float, 0, 1) var period_random = 0

# The initial time in seconds through the cycle. For example, if the period is
# 2 seconds and the period offset is 1 second, the sine behavior starts
# half way through a cycle.
export(float) var period_offset = 0

# A random number of seconds added to the period offset for each instance.
# This can help vary the appearance when a lot of instances are using the
# Sine behavior.
export(float, 0, 1) var period_offset_random = 0

# The maximum change in the object's position, size or angle. This is in
# pixels for position or size modes, or degrees for the angle mode.
export(float) var magnitude = 64 setget set_magnitude

# A random value to add to the magnitude for each instance.
# This can help vary the appearance when a lot of instances are using
# the Sine behavior.
export(float, 0, 1) var magnitude_random = 0


var _init_position : Vector2

var _current_cycle : float


func _ready() -> void:
	var _parent = get_parent()
	
	_init_position = _parent.get_position()
	
	#Initialize period, period_offset, and magnitude random
	#by their respective random value
	period -= period * rand_range(0, period_random)
	period_offset -= period_offset * rand_range(0, period_offset_random)
	magnitude -= magnitude * rand_range(0, magnitude_random)
	
	_current_cycle += period_offset
	
	if wave == null:
		push_warning(str(self.get_path(), " Curve's property is not specified. No action was taken."))


func _process(delta: float) -> void:
	if process_mode == PROCESS_TYPE.IDLE:
		_do_process(delta)


func _physics_process(delta: float) -> void:
	if process_mode == PROCESS_TYPE.PHYSICS:
		_do_process(delta)


func is_active() -> bool:
	return active_on_start


# Enable or disable the behavior. When disabled, the behavior does not
# affect the object at all.
func set_active(var value : bool) -> void:
	active_on_start = value


# Set process how the object moves from a chosen behavior:
# - Idle: Update once per frame.
# - Physics: Update and sync with physics.
func set_process_mode(var value : int) -> void:
	process_mode = value


# Set the progress through one cycle of the chosen wave, from 0
# (the beginning of the cycle) to 1 (the end of the cycle). For example
# setting the cycle position to 0.5 will put it half way through the
# repeating motion.
func set_cycle_position(var value : float) -> void:
	_current_cycle = value


# Set the current magnitude of the cycle. This is in pixels when modifying 
# the size or position, and degrees when modifying the angle.
func set_magnitude(var value : float) -> void:
	magnitude = value


# Change the movement type of the behavior, e.g. from Horizontal to Vertical.
func set_movement(var value : int) -> void:
	movement = value


# Set the duration of a single complete back-and-forth cycle, in seconds.
func set_period(var value : float) -> void:
	period = value


# Change the wave property of the behavior, choosing a different wave 
# function to be used to calculate the movement.
func set_wave(var resource : Curve) -> void:
	wave = resource


func _do_process(delta: float) -> void:
	var _parent = get_parent()
	if not is_active():
		return
	if wave == null:
		return
	
	var calculated_interpolate_wave = wave.interpolate_baked(_current_cycle / period) * magnitude
	
	if _parent is Node2D:
		if movement == MOVEMENT_TYPE.HORIZONTAL:
			_parent.position.x = _init_position.x + calculated_interpolate_wave - (magnitude / 2)
		if movement == MOVEMENT_TYPE.VERTICAL:
			_parent.position.y = _init_position.y + calculated_interpolate_wave - (magnitude / 2)
		if movement == MOVEMENT_TYPE.ANGLE:
			_parent.rotation_degrees = calculated_interpolate_wave
		if movement == MOVEMENT_TYPE.OPACITY:
			_parent.modulate.a8 = calculated_interpolate_wave
	if _parent is Control:
		if movement == MOVEMENT_TYPE.HORIZONTAL:
			_parent.rect_position.x = _init_position.x + calculated_interpolate_wave - (magnitude / 2)
		if movement == MOVEMENT_TYPE.VERTICAL:
			_parent.rect_position.y = _init_position.y + calculated_interpolate_wave - (magnitude / 2)
		if movement == MOVEMENT_TYPE.ANGLE:
			_parent.rect_rotation = calculated_interpolate_wave
		if movement == MOVEMENT_TYPE.OPACITY:
			_parent.modulate.a8 = calculated_interpolate_wave
	
	_current_cycle += delta
	if _current_cycle > period:
		_current_cycle -= period
