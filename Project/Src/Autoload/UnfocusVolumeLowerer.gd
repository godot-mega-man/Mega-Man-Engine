# Lowers the volume automatically when the windows is not focused, and turn
# back on if focused.

extends Node


const VOLUME_dB_LOWER = -15.0
const VOLUME_dB_NORMAL = 0.0


var disabled : bool


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_FOCUS_IN:
		reset()
	if what == NOTIFICATION_WM_FOCUS_OUT:
		lower()


func lower():
	if disabled:
		return
	
	AudioServer.set_bus_volume_db(0, VOLUME_dB_LOWER)


func reset():
	if disabled:
		return
	
	AudioServer.set_bus_volume_db(0, VOLUME_dB_NORMAL)
