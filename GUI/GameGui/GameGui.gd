#GameGui (Iterable Compatible)
#Code by : First

extends CanvasLayer

signal inventory_btn_pressed
signal pause_btn_pressed
signal map_btn_pressed

onready var player = get_node("/root/Level/Iterable/Player")
onready var player_camera = player.camera
onready var global_var = $"/root/GlobalVariables"
onready var currency_manager = get_node("/root/CurrencyManager")
onready var player_stats = get_node("/root/PlayerStats")

#Child nodes
onready var control = $Control
onready var hp_bar = control.get_node("ReferenceGui/HpBar")
onready var hp_text = control.get_node("ReferenceGui/HpTextHBox/HpText")
onready var hp_text_tween = hp_text.get_node("Tween")
onready var mp_bar = control.get_node("ReferenceGui/MpBar")
onready var coin_text = control.get_node("ReferenceGui/CoinText")
onready var coin_text_tween = coin_text.get_node("Tween")
onready var exp_bar = control.get_node("ExpBar")
onready var exp_bar_tween = exp_bar.get_node("Tween")
onready var show_hide_gui_player = control.get_node("ShowHideGuiPlayer")
onready var pause_btn = control.get_node("PauseButton")
onready var tooltip_controller = get_node("Control/TooltipController")
#Lookup nodes
onready var control_interface = get_node("/root/Level/ControlInterface") as ControlInterface
onready var fade_screen = get_node("/root/Level/FadeScreen") as FadeScreen

var is_gui_hidden : bool = false

func _ready():
	#Init values
	hp_bar.init_health_bar(0, player.max_hp, player.current_hp)
	mp_bar.init_health_bar(0, player.max_mp, player.current_mp)
	exp_bar.init_health_bar(0, player_stats.experience_point_next, player_stats.experience_point)
	
	#Show GUI on start.
	control.visible = true
	
	update_gui_bar()
	update_coin()
	update_exp()

func update_gui_bar():
	#Tween text label
	hp_text.init_and_tween(player.current_hp)
	hp_bar.update_hp_bar(player.current_hp)
	mp_bar.update_hp_bar(player.current_mp)

func update_coin():
	#Tween text label
	coin_text.init_and_tween(currency_manager.game_coin)
	coin_text.show_coin_text()

func update_exp():
	exp_bar.update_hp_bar(player_stats.experience_point)

#Show/Hide GUI
func hide_all_gui():
	show_hide_gui_player.play("Hide Gui")
	is_gui_hidden = true

func show_all_gui():
	show_hide_gui_player.play("Show Gui")
	is_gui_hidden = false

#To do code when pause button is pressed.
func _on_PauseButton_pressed() -> void:
	emit_signal("pause_btn_pressed")

#To do code when the inventory button is pressed.
func _on_InventoryButton_pressed() -> void:
	emit_signal("inventory_btn_pressed")

func _on_MapButton_pressed() -> void:
	emit_signal("map_btn_pressed")

#When fading screen is started, disable all buttons.
func _on_FadeScreen_fading_started() -> void:
	enable_buttons(false)

#When fading screen is finished, enable all buttons.
func _on_FadeScreen_fading_finished() -> void:
	enable_buttons(true)

#When player dies, disable all buttons
func _on_Player_player_die() -> void:
	enable_buttons(false)

func enable_buttons(var set : bool):
	set = !set #Inverse
	pause_btn.disabled = set

func add_item_collect_tooltip(new_header_label : String, new_quan_label : int = 0, new_icon_texture = null, new_rarity = 0):
	tooltip_controller.add_collected_item_tooltip(new_header_label, new_quan_label, new_icon_texture, new_rarity)