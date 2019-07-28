# TOOLTIP BOX
# CODE BY: FIRST

# THIS BOX CONTAINS INFORMATION ABOUT ITEM COLLECTED.
# THIS INCLUDES: AN ICON, A HEADER WITH MODIFYABLE COLOR,
# AND A SMALL DESCRIPTION.

extends Control

#Child nodes
onready var tooltip_box = $TooltipBox
onready var tooltip_icon : TextureRect = $TooltipBox/HBoxContainer/TooltipIcon setget set_tooltip_icon, get_tooltip_icon
onready var header_label = $TooltipBox/HBoxContainer/VBoxContainer/HBoxContainer/HeaderLabel setget set_header_label, get_header_label
onready var desc_label = $TooltipBox/HBoxContainer/VBoxContainer/HBoxContainer/QuantityLabel setget set_quantity_label, get_quantity_label
onready var pop_out_timer = $PopOutTimer
onready var animation_player = $AnimationPlayer
onready var tween = $Tween

var is_time_out : bool = false

const SLIDE_DURATION = 0.4
const OFFSET_X = -4

#GETTER/SETTER FUNCTIONS
func set_tooltip_icon(new_value) -> void:
	tooltip_icon.set_texture(new_value)
func get_tooltip_icon():
	return tooltip_icon.get_texture()
func set_header_label(new_value : String) -> void:
	header_label.set_text(new_value)
func get_header_label() -> String:
	return header_label.get_text()
func set_quantity_label(new_value : int) -> void:
	var text_to_set : String
	if new_value > 1:
		text_to_set = str("(", new_value, ")")
	else:
		text_to_set = ""
	desc_label.set_text(text_to_set)
func get_quantity_label() -> String:
	return desc_label.get_text()

func _ready() -> void:
	slide_in()

func slide_in():
	tween.interpolate_property(tooltip_box, "rect_position:x", -self.rect_size.x, OFFSET_X, SLIDE_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tooltip_box.rect_position.x = -self.rect_size.x
	tween.start()

func slide_out():
	tween.interpolate_property(tooltip_box, "rect_position:x", OFFSET_X, -self.rect_size.x, SLIDE_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

func initiate(new_header_label : String, new_quan_label : int = 1, new_icon_texture = null, new_rarity = 0) -> void:
	set_header_label(new_header_label)
	set_quantity_label(new_quan_label)
	set_tooltip_icon(new_icon_texture)
	set_rarity_text_color(new_rarity)

func set_rarity_text_color(new_rarity):
	var rarity_color = FJ_Res_Item.ITEM_RARITY_COLOR.get(new_rarity)
	header_label.add_color_override("font_color", rarity_color)

#Refresh time, allowing a new stack to be added here.
#Ideally good with number of quantity.
func refresh_time() -> void:
	if is_time_out:
		return
	
	pop_out_timer.start()

#When timer runs out, refreshing pop-out time will be disabled.
#Stacking item's quantity when collecting the same item will be
#ignored after that.
func _on_PopOutTimer_timeout() -> void:
	is_time_out = true
	animation_player.play("Disappear")
