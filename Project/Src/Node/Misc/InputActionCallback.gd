# InputActionCallback
#
# Emits signals when any action key is pressed or released. Useful for
# cutscene and message box skipping.
#
# Optionally, you can set which keys are only allowed for the signals to be
# emitted.

extends Node


signal just_pressed(action)

signal just_released(action)


const AB_START_ACTIONS = ["ui_accept", "game_shoot", "game_jump"]


# Action keys that are only allowed for the signals to be emitted.
# All action keys will be allowed if it's an empty array.
export var allowed_actions : PoolStringArray = []

# If true, variable 'allowed_actions' will be replaced with a pre-defined
# action keys instead.
export var emit_ab_start_only : bool


func _input(event: InputEvent) -> void:
	_action_emit(event)


# Returns true if the given action will emit a signal whether an action is
# pressed or released. 
func can_emit(action : String) -> bool:
	if emit_ab_start_only:
		return action in AB_START_ACTIONS
	if not allowed_actions.empty():
		return action in allowed_actions
	
	return action in InputMap.get_actions()


func _action_emit(event : InputEvent):
	if not event is InputEventKey:
		return
	
	var _actions = InputMap.get_actions()
	
	for action in _actions:
		if not can_emit(action):
			continue
		
		if Input.is_action_just_pressed(action):
			emit_signal("just_pressed", action)
		if Input.is_action_just_released(action):
			emit_signal("just_released", action)
