#Player's Coin Text
#Code by: First

#TWEENS THE TEXT, AUTOMATICALLY SHOW AND HIDE WHEN NOT IN USE.
#HARD CODED. NOT ADVISED TO MODIFY OR MAKE CHANGES.

extends "res://GUI/HpText/HpText.gd"

export (Vector2) var offset = Vector2(0,0)
export (float) var display_time = 2.0

#Child nodes
onready var hide_timer = $HideTimer
onready var show_hide_player = $ShowHidePlayer
onready var wobble_player = $WobblePlayer

#Temp Variables
var origin_rect_position : Vector2
var is_showing = false
var re_show = false

func _ready() -> void:
	origin_rect_position = rect_position #Set origin to avoid unexpected re-positioning rect_pos
	
	hide_timer.connect("timeout", self, '_on_hide_timer_timeout')
	show_hide_player.connect("animation_finished", self, '_on_show_hide_player_finished')
	hide_timer.wait_time = display_time

func _process(delta: float) -> void:
	rect_position = origin_rect_position + offset

func show_coin_text():
	if show_hide_player.current_animation == "Hide":
		re_show = true
		return
	
	if !is_showing:
		show_hide_player.play("Show")
		is_showing = true
	hide_timer.start()
	
	#Make text wobbles
	wobble_player.play("New Anim")

#Time to hide
func _on_hide_timer_timeout():
	show_hide_player.play("Hide")

func _on_show_hide_player_finished(anim):
	if anim == 'Hide':
		is_showing = false
		
		#If coin is recently picked up while animation is being hided, show again.
		if re_show:
			show_coin_text()
		re_show = false
