extends Node

signal bgm_just_started(bgm_name)

#Bgm
onready var bgm_core : AudioStreamPlayer = $BgmCore_DONT_TOUCH_THIS
onready var property_setter_player : AnimationPlayer = $BgmCore_DONT_TOUCH_THIS/PropertySetterPlayer

#Sfx
onready var sfx_player_damage : AudioStreamPlayer = $Sfx_PlayerDamage
onready var sfx_player_die : AudioStreamPlayer = $Sfx_PlayerDie
onready var sfx_enemy_damage : AudioStreamPlayer = $Sfx_EnemyDamage
onready var sfx_enemy_collapse : AudioStreamPlayer = $Sfx_EnemyCollapse
onready var sfx_coin : AudioStreamPlayer = $Sfx_Coin
onready var sfx_coin_landing : AudioStreamPlayer = $Sfx_CoinLanding
onready var sfx_shot : AudioStreamPlayer = $Sfx_Shot
onready var sfx_level_up : AudioStreamPlayer = $Sfx_LevelUp
onready var sfx_reflect : AudioStreamPlayer = $Sfx_Reflect
onready var sfx_landing : AudioStreamPlayer = $Sfx_Landing

var current_bgm : String #Path

#Call by Level.
func play_bgm(var what_bgm : AudioStreamOGGVorbis):
	if what_bgm == null:
		return
	var new_bgm_path : String = what_bgm.get_path()
	
	if new_bgm_path != current_bgm:
		bgm_core.set_stream(what_bgm)
		bgm_core.play()
		current_bgm = new_bgm_path
		emit_signal("bgm_just_started", what_bgm.get_path().replace("res://Audio/Bgm/", "").replace(".ogg", ""))

func stop_bgm():
	bgm_core.stop()
	current_bgm = ""

func set_all_sfx_volume(vol : float):
	for i in self.get_children():
		if i != get_node("BgmCore_DONT_TOUCH_THIS"):
			i.volume_db = vol

func dim_bgm():
	property_setter_player.play("Dim")

func undim_bgm():
	property_setter_player.play("Undim")

func fade_out_bgm(var stop_bgm_after_faded : bool = false):
	if stop_bgm_after_faded:
		property_setter_player.play("FadeOutStop")
	else:
		property_setter_player.play("FadeOutNoStop")