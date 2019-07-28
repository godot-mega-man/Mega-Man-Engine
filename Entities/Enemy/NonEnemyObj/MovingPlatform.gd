extends EnemyCore

onready var sine_bhv = $SineBehavior
export (float) var magnitude = 64 setget _set_magnitude
export (float) var period = 4 setget _set_period
export (float) var period_offset = 0 setget _set_period_offset

func _set_magnitude(val):
	magnitude = val
	sine_bhv.magnitude = val

func _set_period(val):
	period = val
	sine_bhv.period = val

func _set_period_offset(val):
	period_offset = val
	sine_bhv.period_offset = val