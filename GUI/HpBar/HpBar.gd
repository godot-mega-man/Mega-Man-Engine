extends TextureProgress

export (bool) var affects_game_settings = true

onready var hp_bar = $HpBar

var previous_value_primary_bar = 0 #Actual Health Bar
var previous_value_secondary_bar = 0 #Secondary Bar
var primary_is_decreasing = false
var secondary_is_decreasing = false

func _ready():
	pass

func init_health_bar(var min_hp, var max_hp, var current_value):
	min_value = min_hp
	max_value = max_hp
	value = current_value
	hp_bar.min_value = min_hp
	hp_bar.max_value = max_hp
	hp_bar.value = current_value

func update_min_max(var min_hp, var max_hp):
	hp_bar.min_value = min_hp
	hp_bar.max_value = max_hp
	min_value = min_hp
	max_value = max_hp

func update_hp_bar(new_value, main_duration : float = 0.25, sub_increasing_duration : float = 0.01):
	if hp_bar.value < new_value:
		self.primary_is_decreasing = false
	else:
		self.primary_is_decreasing = true
	if self.value < new_value:
		self.secondary_is_decreasing = false
	else:
		self.secondary_is_decreasing = true
	previous_value_primary_bar = hp_bar.value
	previous_value_secondary_bar = self.value
	#Tween health smoothly
	$Tween.interpolate_property(hp_bar, 'value', previous_value_primary_bar, clamp(new_value, 0, INF), main_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	#Slowly tween secondary bar.
	if self.secondary_is_decreasing:
		$Tween.interpolate_property(self, 'value', previous_value_secondary_bar, clamp(new_value, 0, INF), 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	else:
		$Tween.interpolate_property(self, 'value', previous_value_secondary_bar, clamp(new_value, 0, INF), sub_increasing_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	
	$Tween.start()