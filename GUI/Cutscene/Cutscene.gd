#CUTSCENE
#CODE BY : FIRST

#CUTSCENE THAT SHOWS BLACK BAR AT THE TOP AND BOTTOM OF THE
#SCREEN.

extends CanvasLayer
class_name CutScene

#Child nodes
onready var color_rect_top = $Control/ColorRectTop
onready var color_rect_bottom = $Control/ColorRectBottom
onready var animation_player = $AnimationPlayer

func cutscene_enable(enable : bool):
	if enable:
		animation_player.play("Show")
	else:
		animation_player.play("Hide")
