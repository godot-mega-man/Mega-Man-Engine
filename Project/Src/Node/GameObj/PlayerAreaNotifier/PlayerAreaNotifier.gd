# PlayerAreaNotifier


extends ReferenceRect


signal entered_area


export (int, "FORCED", "PLAYER INTERACTION", "DISABLED") var INTERACT_TYPE = 0

export (bool) var PLAYER_ON_FLOOR_ONLY = false


onready var tap_texture = $TapTexture

onready var player = $"/root/Level/Iterable/Player"

onready var global_var = $"/root/GlobalVariables"

onready var player_stats = get_node("/root/PlayerStats")


var is_player_in_area = false


func _ready():
	expand_area()
	if !Engine.is_editor_hint():
		$Label.queue_free()


func expand_area():
	self.get_node("Area2D/CollisionShape2D").shape = RectangleShape2D.new()
	self.get_node("Area2D/CollisionShape2D").shape.extents = self.rect_size / 2
	self.get_node("Area2D/CollisionShape2D").position = self.rect_size / 2


func update_tap_gui_button():
	tap_texture.visible = is_player_in_area


func show_hide_tap_button(var what : bool):
	tap_texture.visible = what


func _on_Area2D_area_entered(area):
	if area.get_parent() is Player:
		is_player_in_area = true
		#Check if this warp zone is disabled.
		if INTERACT_TYPE == 2:
			return
		
		if INTERACT_TYPE == 0: #Forced
			entered_area()
			return
		update_tap_gui_button()


func _on_Area2D_area_exited(area):
	if area.get_parent() is Player:
		if INTERACT_TYPE == 1: #Player's interaction
			is_player_in_area = false
			update_tap_gui_button()


func entered_area():
	#Playe must not die
	if player_stats.is_died:
		return
	
	emit_signal("entered_area")
