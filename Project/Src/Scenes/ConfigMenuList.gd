extends MenuList


const OPTION_SCALE = 0
const OPTION_FULLSCREEN_TOGGLE = 1
const OPTION_BGM = 2
const OPTION_SFX = 3
const OPTION_DMG = 4
const OPTION_OBJ_OVERLAP = 5
const OPTION_NES_SLOWDOWN = 6
const OPTION_CONFIRM = 7
const OPTION_KEYBOARD = 8


onready var cursor_position_references = [
	$VBoxContainer/Scale,
	$VBoxContainer/FullScreenToggle,
	$VBoxContainer/BgmVol,
	$VBoxContainer/SfxVol,
	$VBoxContainer/Dmg,
	$VBoxContainer/ObjOverlap,
	$VBoxContainer/NesSlowdown,
	$VBoxContainer/Exit,
	$VBoxContainer/Keyboard
]


func _ready() -> void:
	_update_cursor_position()
	_update_texts()
	GameSettings.gameplay.connect("screen_scale_changed", self, "_on_GameSettingsGameplay_screen_scale_changed")


func _action_pressed(action : String): # Overrides
	if action == "ui_up":
		move_cursor(-1)
	if action == "ui_down":
		move_cursor(1)
	if action == "ui_left":
		adjust(-1)
	if action == "ui_right":
		adjust(1)
	if action == "ui_accept":
		press()


func adjust(direction : int):
	if direction == -1: # LEFT
		if cursor_position == OPTION_SCALE:
			GameSettings.gameplay.screen_scale -= 1
		elif cursor_position == OPTION_BGM:
			GameSettings.audio.bgm_volume -= 4
			_update_texts()
			return
		elif cursor_position == OPTION_SFX:
			GameSettings.audio.sfx_volume -= 4
		elif cursor_position == OPTION_DMG:
			GameSettings.gameplay.damage_popup_enemy = !GameSettings.gameplay.damage_popup_enemy
			GameSettings.gameplay.damage_popup_player = GameSettings.gameplay.damage_popup_enemy
		elif cursor_position == OPTION_OBJ_OVERLAP:
			GameSettings.gameplay.sprite_flicker = !GameSettings.gameplay.sprite_flicker
		elif cursor_position == OPTION_NES_SLOWDOWN:
			GameSettings.gameplay.nes_slowdown = !GameSettings.gameplay.nes_slowdown
		else:
			return
	if direction == 1: # RIGHT
		if cursor_position == OPTION_SCALE:
			GameSettings.gameplay.screen_scale += 1
		elif cursor_position == OPTION_BGM:
			GameSettings.audio.bgm_volume += 4
			_update_texts()
			return
		elif cursor_position == OPTION_SFX:
			GameSettings.audio.sfx_volume += 4
		elif cursor_position == OPTION_DMG:
			GameSettings.gameplay.damage_popup_enemy = !GameSettings.gameplay.damage_popup_enemy
			GameSettings.gameplay.damage_popup_player = GameSettings.gameplay.damage_popup_enemy
		elif cursor_position == OPTION_OBJ_OVERLAP:
			GameSettings.gameplay.sprite_flicker = !GameSettings.gameplay.sprite_flicker
		elif cursor_position == OPTION_NES_SLOWDOWN:
			GameSettings.gameplay.nes_slowdown = !GameSettings.gameplay.nes_slowdown
		else:
			return
	
	Audio.play_sfx("start")
	_update_texts()


func press():
	if cursor_position == OPTION_FULLSCREEN_TOGGLE:
		ScreenSizeSetter.toggle_fullscreen()
	elif cursor_position == OPTION_DMG:
		GameSettings.gameplay.damage_popup_enemy = !GameSettings.gameplay.damage_popup_enemy
		GameSettings.gameplay.damage_popup_player = !GameSettings.gameplay.damage_popup_enemy
	elif cursor_position == OPTION_OBJ_OVERLAP:
		GameSettings.gameplay.sprite_flicker = !GameSettings.gameplay.sprite_flicker
	elif cursor_position == OPTION_NES_SLOWDOWN:
		GameSettings.gameplay.nes_slowdown = !GameSettings.gameplay.nes_slowdown
	elif cursor_position == OPTION_CONFIRM:
		emit_signal("confirmed")
	else:
		return
	
	Audio.play_sfx("start")
	_update_texts()


func move_cursor(direction : int):
	cursor_position += direction
	cursor_position = fposmod(cursor_position, get_menu_button_count())
	Audio.play_sfx("select")
	_update_cursor_position()


func get_menu_button_count() -> int:
	return cursor_position_references.size()


# Connects from _ready()
func _on_GameSettingsGameplay_screen_scale_changed():
	_update_texts()


func _update_cursor_position():
	$Cursor.rect_position.y = cursor_position_references[cursor_position].rect_position.y


func _update_texts():
	$VBoxContainer/Scale/Value.text = str(
		"x",
		GameSettings.gameplay.screen_scale + 1
	)
	$VBoxContainer/BgmVol/Value.text = str(
		int((GameSettings.audio.bgm_volume + 80) / 80 * 100)
	)
	$VBoxContainer/SfxVol/Value.text = str(
		int((GameSettings.audio.sfx_volume + 80) / 80 * 100)
	)
	$VBoxContainer/Dmg/Value.text = "On" if GameSettings.gameplay.damage_popup_enemy else "Off"
	$VBoxContainer/ObjOverlap/Value.text = "On" if GameSettings.gameplay.sprite_flicker else "Off"
	$VBoxContainer/NesSlowdown/Value.text = "On" if GameSettings.gameplay.nes_slowdown else "Off"
	if GameSettings.gameplay.nes_slowdown:
		$VBoxContainer/NesSlowdown/Warn.show()
	else:
		$VBoxContainer/NesSlowdown/Warn.hide()

