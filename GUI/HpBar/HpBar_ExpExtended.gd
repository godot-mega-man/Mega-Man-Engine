#Player's Exp Bar
#Code by: First

#AUTOMATICALLY SHOW AND HIDE WHEN NOT IN USE.
#EXTREMELY HARD CODED. NOT ADVISED TO MODIFY OR MAKE CHANGES.

extends "res://GUI/HpBar/HpBar.gd"

onready var hide_timer = $HideTimer
onready var exp_text = $ExpText
onready var animation_player = $AnimationPlayer

onready var global_var = $"/root/GlobalVariables"
onready var player_stats = get_node("/root/PlayerStats")

var hide_at_initial = true

func _ready():
	hide_timer.connect("timeout", self, "_on_hide_timer_timeout")

func _on_hide_timer_timeout():
	animation_player.play("Fade")

#This will be called at the start of the scene.
func update_hp_bar(new_value):
	#Hide at initial? 
	if hide_at_initial:
		hide_at_initial = false
		self.visible = false
		return
	
	previous_value_primary_bar = hp_bar.value
	previous_value_secondary_bar = self.value
	#Tween health smoothly
	$Tween.interpolate_property(hp_bar, 'value', previous_value_primary_bar, clamp(new_value, 0, INF), 2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	#Slowly tween secondary bar.
	$Tween.interpolate_property(self, 'value', previous_value_secondary_bar, clamp(new_value, 0, INF), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	
	#Start to hide after some time.
	self.visible = true
	hide_timer.start()
	
	#SET EXP TEXT...
	update_exp_text()
	
	#Play animation
	animation_player.play("Brightern")
	update_min_max(0, player_stats.experience_point_next)

#This will update exp text.
#Text pattern is: CURRENT/NEXT
# Ex: 25/100 
func update_exp_text():
	exp_text.text = str(player_stats.experience_point) + '/' + str(player_stats.experience_point_next)