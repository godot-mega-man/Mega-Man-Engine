extends CanvasLayer
class_name ControlInterface

#Child nodes
onready var control = $Control
onready var show_hide_gui_player = $ShowHideGuiPlayer
onready var buttons_control = $Control/Buttons
onready var btn_interact = buttons_control.get_node("BtnInteract")

func _ready() -> void:
	if OS.get_name() == "Windows": return;
	control.visible = true

func hide_all_gui():
	show_hide_gui_player.play("Hide Gui")
func show_all_gui():
	show_hide_gui_player.play("Show Gui")

func set_visible_interact_button(vis : bool):
	btn_interact.visible = vis