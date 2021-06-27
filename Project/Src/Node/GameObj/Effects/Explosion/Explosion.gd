extends Sprite


#Delay in seconds before starting animation. This automatically
#manages Timer node.
export (float) var start_animation_delay setget _set_start_animation_delay


onready var start_delay_timer = $StartDelayTimer

onready var ani_player = $AnimationPlayer


func _ready() -> void:
	if start_animation_delay > 0:
		start_delay_timer.start(start_animation_delay)
	else:
		play_animation()


func play_animation():
	ani_player.play("Explodse")


func set_color(color : Color) -> void:
	modulate = color


func _set_start_animation_delay(new_value : float):
	start_animation_delay = new_value


func _on_StartDelayTimer_timeout() -> void:
	play_animation()
