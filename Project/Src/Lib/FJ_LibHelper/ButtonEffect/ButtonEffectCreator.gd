# Button Effect Creator
# 
# Creates effect for the button whether the button is pressed.

class_name FJ_ButtonEffectCreator1 extends Node


export var effect_color : Color = Color('ffffff')

export (float, 0.01, 16.0, 0.01) var effect_speed = 1.0

export (int, "Horizontal Open", "Vertical Open", "Expand_From_Center") var effect_type = 0


onready var parent_node


var effect = preload("res://Src/Lib/FJ_LibHelper/ButtonEffect/ButtonEffect.tscn")


func _ready():
	parent_node = get_parent()
	
	#Checks if parent node is Button
	#If not, this node will be instantly self-destruct.
	if is_parent_node_valid():
		parent_node.connect("pressed", self, "_on_button_pressed")
	else:
		self.queue_free()


func is_parent_node_valid() -> bool:
	return parent_node is Button


#When button is pressed, the button touch effect will be created.
#Also check if button touch effect is still exists (playing),
#button touch effect will be play again without creating a new one.
func _on_button_pressed():
	if parent_node.has_node("ButtonEffect"):
		parent_node.get_node("ButtonEffect").animation_player.stop()
		parent_node.get_node("ButtonEffect").animation_player.play("New Anim")
	else:
		var ef = effect.instance()
		parent_node.add_child(ef)
		ef.set_effect_color(effect_color)
		ef.set_animation_duration(effect_speed)
		ef.set_effect_type(effect_type)
