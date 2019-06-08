extends Label

export (bool) var UPDATE_ONCE_PER_FRAME = true

var previous_value = 0
var current_value = 0
var tweening_val = 0
var is_updated = false

const TWEEN_DURATION = 0.3

#Child nodes
onready var tween = $Tween

func _process(delta):
	self.text = str(round(tweening_val))
	if is_updated:
		is_updated = false
		tween.start()

func init_and_tween(new_val):
	current_value = clamp(new_val, 0, INF)
	tween_action()
	if !is_updated or !UPDATE_ONCE_PER_FRAME:
		previous_value = current_value
	
	is_updated = true

func tween_action():
	tween.interpolate_property(self, 'tweening_val', previous_value, current_value, TWEEN_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)