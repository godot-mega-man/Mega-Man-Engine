extends CanvasLayer

class_name BossHealthBar

signal filled_up_bar_to_max
signal hiding_bar

onready var hp_bar := $Control/SecondaryBar
onready var show_hide_player := $Control/SecondaryBar/ShowHidePlayer
onready var boss_name_label = $Control/SecondaryBar/BossNameLabel
onready var hp_text = $Control/SecondaryBar/HBoxContainer/HpText
onready var fill_up_signal_timer := $FillUpSignalTimer

#Temp
var current_max_hp : float
var current_hp : float

func _init() -> void:
	current_max_hp = 0
	current_hp = 0

func _ready() -> void:
	hp_bar.set_visible(false)

func show_health_bar(max_hp : float, boss_name : String):
	hp_bar.init_health_bar(0, max_hp, 0)
	current_max_hp = max_hp
	current_hp = max_hp
	show_hide_player.play("Show")
	if not boss_name.empty():
		boss_name_label.text = boss_name

func fill_up_hp(var duration : float):
	#Call hp bar to update health bar to max by slowly filling up.
	#Sends three parameters as follows: MAX_HP, duration from the boss's parameter,
	#and sub white_bar that goes ahead main_bar for 0.1 seconds.
	hp_bar.update_hp_bar(hp_bar.max_value, duration, duration - 0.1)
	
	#Update hp text and tween the value smoothly.
	update_percentage_text(duration)
	
	#Plays Boss fill up health sound
	FJ_AudioManager.sfx_ui_boss_fill_hp.play()
	fill_up_signal_timer.start(duration)

func _on_FillUpSignalTimer_timeout() -> void:
	emit_signal("filled_up_bar_to_max")
	FJ_AudioManager.sfx_ui_boss_fill_hp.stop()

func update_health_bar(curr_value) -> void:
	hp_bar.update_hp_bar(curr_value)
	current_hp = curr_value
	update_percentage_text(0.3)

func hide_health_bar():
	if get_tree().get_nodes_in_group("Boss").size() <= 1:
		show_hide_player.play("Hide")
		emit_signal("hiding_bar")

func update_percentage_text(var duration : float):
	hp_text.tween_duration = duration
	hp_text.init_and_tween(current_hp / current_max_hp * 100)