#Button Plus
#Code by: First

#A button object that produces click effect when
#pressed. Click effect can also be configured.

#Usage: No need to instance as child node. You can
#directly create a new node as ButtonPlus.

extends Button

class_name ButtonPlus

export (bool) var press_effect_enabled = true
export var button_effect_color : Color = Color('ffffff')
export (float, 0.01, 16.0, 0.01) var button_effect_speed = 1.0
export (int, "Horizontal Open", "Vertical Open", "Expand_From_Center") var button_effect_type = 0

#Preload
var btn_effect_creator = preload("res://Lib/FJ_LibHelper/ButtonEffect/ButtonEffectCreator.tscn")

func _ready():
	self.connect("pressed", self, "_on_sys_self_pressed")
	_create_btn_effect_creator()

func _on_sys_self_pressed():
	FJ_AudioManager.sfx_ui_button.play()

func _create_btn_effect_creator():
	if not press_effect_enabled:
		return
	
	var obj = btn_effect_creator.instance()
	add_child(obj)
	obj.effect_color = button_effect_color
	obj.effect_speed = button_effect_speed
	obj.effect_type = button_effect_type