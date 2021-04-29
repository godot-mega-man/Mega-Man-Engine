extends CanvasLayer

signal boss_vital_bar_fully_filled

onready var player_vital_node2d := $PlayerVitalBar
onready var player_vital_bar := $PlayerVitalBar/Bar as Sprite
onready var player_vital_bar_palette := $PlayerVitalBar/Bar/PaletteSprite as PaletteSprite
onready var player_vital_bar_delay_timer := $PlayerVitalBar/Bar/DelayTimer

onready var player_weapon_node2d := $PlayerWeaponBar
onready var player_weapon_bar := $PlayerWeaponBar/Bar as Sprite
onready var player_weapon_bar_palette := $PlayerWeaponBar/Bar/PaletteSprite as PaletteSprite
onready var player_weapon_bar_delay_timer := $PlayerWeaponBar/Bar/DelayTimer

onready var boss_vital_node2d := $BossVitalBar
onready var boss_vital_bar := $BossVitalBar/Bar as Sprite
onready var boss_vital_bar_palette := $BossVitalBar/Bar/PaletteSprite as PaletteSprite
onready var boss_vital_bar_delay_timer := $BossVitalBar/Bar/DelayTimer

var remaining_player_vital_fill : int = 0
var remaining_player_weapon_fill : int = 0
var remaining_boss_vital_fill : int = 0

var is_filling := false


func _ready() -> void:
	#Default
	reset_all_bars_to_default_color()

func _process(delta: float) -> void:
	if player_weapon_bar.frame > 28:
		player_weapon_bar.frame = 28

func update_player_weapon_bar_colors(var primary_color : Color, var secondary_color : Color, var outline_color : Color):
	player_weapon_bar_palette.primary_sprite.modulate = primary_color
	player_weapon_bar_palette.second_sprite.modulate = secondary_color
	player_weapon_bar_palette.outline_sprite.modulate = outline_color

func update_boss_vital_bar_colors(var primary_color : Color, var secondary_color : Color, var outline_color : Color):
	boss_vital_bar_palette.primary_sprite.modulate = primary_color
	boss_vital_bar_palette.second_sprite.modulate = secondary_color
	boss_vital_bar_palette.outline_sprite.modulate = outline_color

func update_player_vital_bar(points : int):
	player_vital_bar.frame = int(clamp(points, 0, 28))

func update_player_weapon_bar(points : int):
	player_weapon_bar.frame = int(clamp(points, 0, 28))

func update_boss_vital_bar(points : int):
	boss_vital_bar.frame = int(clamp(points, 0, 28))

func fill_player_vital_bar(value : int):
	remaining_player_vital_fill += value
	_fill_process_start()

func fill_player_weapon_bar(value : int):
	remaining_player_weapon_fill += value
	_fill_process_start()

func fill_boss_vital_bar(value : int):
	remaining_boss_vital_fill += value
	_fill_process_start()

func reset_all_bars_to_default_color():
	player_vital_bar_palette.primary_sprite.modulate = NESColorPalette.WHITE4
	player_vital_bar_palette.second_sprite.modulate = NESColorPalette.LIGHTSALMON4
	player_vital_bar_palette.outline_sprite.modulate = NESColorPalette.BLACK1
	player_weapon_bar_palette.primary_sprite.modulate = Color("ffe0a8")
	player_weapon_bar_palette.second_sprite.modulate = Color("887000")
	player_weapon_bar_palette.outline_sprite.modulate = NESColorPalette.BLACK1
	boss_vital_bar_palette.primary_sprite.modulate = NESColorPalette.WHITE4
	boss_vital_bar_palette.second_sprite.modulate = NESColorPalette.TOMATO2
	boss_vital_bar_palette.outline_sprite.modulate = NESColorPalette.BLACK1


func hide_all():
	player_vital_bar.visible = false
	player_weapon_bar.visible = false
	boss_vital_bar.visible = false


#Begin filling missing vitals by checking all remaining vitals.
func _fill_process_start():
	if is_filling:
		return
	
	if remaining_player_vital_fill > 0 and player_vital_bar.frame < 28:
		player_vital_bar_delay_timer.start()
#		get_tree().set_pause(true)
		if not FJ_AudioManager.sfx_ui_boss_fill_hp.playing:
			FJ_AudioManager.sfx_ui_boss_fill_hp.play()
		is_filling = true
		return
	if remaining_player_weapon_fill > 0 and player_weapon_bar.frame < 28:
#		get_tree().set_pause(true)
		player_weapon_bar_delay_timer.start()
		if not FJ_AudioManager.sfx_ui_boss_fill_hp.playing:
			FJ_AudioManager.sfx_ui_boss_fill_hp.play()
		is_filling = true
		return
	if remaining_boss_vital_fill > 0 and boss_vital_bar.frame < 28:
		boss_vital_bar_delay_timer.start()
		if not FJ_AudioManager.sfx_ui_boss_fill_hp.playing:
			FJ_AudioManager.sfx_ui_boss_fill_hp.play()
		is_filling = true
		return
	
	get_tree().set_pause(false)
	remaining_player_vital_fill = 0
	remaining_player_weapon_fill = 0
	remaining_boss_vital_fill = 0
	if FJ_AudioManager.sfx_ui_boss_fill_hp.is_playing():
		FJ_AudioManager.sfx_ui_boss_fill_hp.call_deferred("stop")


func _on_PlayerVitalBar_DelayTimer_timeout() -> void:
	player_vital_bar.set_frame(player_vital_bar.frame + 1)
	remaining_player_vital_fill -= 1
	is_filling = false
	_fill_process_start()

func _on_PlayerWeaponBar_DelayTimer_timeout() -> void:
	player_weapon_bar.set_frame(player_weapon_bar.frame + 1)
	remaining_player_weapon_fill -= 1
	is_filling = false
	_fill_process_start()

func _on_BossVitalBar_DelayTimer_timeout() -> void:
	boss_vital_bar.set_frame(boss_vital_bar.frame + 1)
	remaining_boss_vital_fill -= 1
	is_filling = false
	if boss_vital_bar.frame >= 28:
		emit_signal("boss_vital_bar_fully_filled")
	_fill_process_start()

func update_life():
	$PlayerVitalBar/Bar/Life.text = str(Life.remaining)
	$PlayerVitalBar/Bar/Life.visible = Difficulty.difficulty != Difficulty.DIFF_NEWCOMER
