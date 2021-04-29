# ActiveVisibilityNotifier2D

extends VisibilityNotifier2D

class_name ActiveVisibilityNotifier2D

"""
	An extended built-in node of VisibilityNotifier2D. Has almost the same
	functionality of the base class, but with more precise visibility detection
	at the cost of performance.
"""

#-------------------------------------------------
#      Classes
#-------------------------------------------------

#-------------------------------------------------
#      Signals
#-------------------------------------------------

# Emitted when the VisibilityNotifier2D enters the visible viewport rect.
signal visibility_entered

# Emitted when the VisibilityNotifier2D exits the visible viewport rect.
signal visibility_exited

#-------------------------------------------------
#      Constants
#-------------------------------------------------

# Type during the processing step of the main loop
enum ProcessType {IDLE, PHYSICS}

enum DetectionType {POINT, BOX}

#-------------------------------------------------
#      Properties
#-------------------------------------------------

# If false, the behavior is in disabled state and won't do anything.
export (bool) var active = true

# The process how the object works from a chosen behavior:
#
# - Idle: Update once per frame.
#
# - Physics: Update and sync with physics.
export(ProcessType) var process_mode = 0

# Mode of how visibility detection will work
#
# - Point: Detection will be determined from a single point.
#
# - Box: Detection will be determined from the area of a rectangle. It's
#   considered hidden if the complete bound is outside the screen.
export (DetectionType) var detection_type = 1

# Size of the area of a rectangle used for detection. Only works when detection
# type is set to 'DetectionType.Box'.
export (Vector2) var detection_box_size = Vector2(16, 16)

# Total frame passed for this node. This is to ensure the process won't work
# on the first frame, because when this node is instantiated right at the start,
# it takes one frame for the node's visibility to be assessed.
var _frame = 0

var vis_enter_emitted : bool

var vis_exit_emitted : bool

var inside : bool

#-------------------------------------------------
#      Notifications
#-------------------------------------------------

func _process(delta: float) -> void:
	call_deferred("_add_frame_counter") # Call at the end of the frame
	
	if process_mode != ProcessType.IDLE:
		return
	
	_do_process()

func _physics_process(delta: float) -> void:
	if process_mode != ProcessType.PHYSICS:
		return
	
	_do_process()

#-------------------------------------------------
#      Virtual Methods
#-------------------------------------------------

#-------------------------------------------------
#      Override Methods
#-------------------------------------------------

#-------------------------------------------------
#      Public Methods
#-------------------------------------------------

func is_inside_visible_viewport_rect() -> bool:
	var result : bool
	
	match detection_type:
		DetectionType.POINT:
			result = get_camera().get_current_screen_rect().has_point(global_position)
		DetectionType.BOX:
			result = get_camera().get_current_screen_rect().intersects(Rect2(global_position - (detection_box_size * 0.5), detection_box_size))
	
	inside = result
	
	return result

func get_camera() -> Camera2D:
	for i in get_tree().get_nodes_in_group("CameraCustom"):
		if i is Camera2D:
			return i
	
	return null

#-------------------------------------------------
#      Connections
#-------------------------------------------------

#-------------------------------------------------
#      Private Methods
#-------------------------------------------------

func _do_process() -> void:
	if _is_first_frame():
		return
	if not active:
		return
	
	if is_inside_visible_viewport_rect():
		if not vis_enter_emitted:
			vis_enter_emitted = true
			vis_exit_emitted = false
			emit_signal("visibility_entered" )
	else:
		if not vis_exit_emitted:
			vis_enter_emitted = false
			vis_exit_emitted = true
			emit_signal("visibility_exited")

func _is_first_frame() -> bool:
	return _frame == 0

func _add_frame_counter() -> void:
	_frame += 1

#-------------------------------------------------
#      Setters & Getters
#-------------------------------------------------
