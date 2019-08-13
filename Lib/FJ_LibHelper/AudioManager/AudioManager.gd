#AudioManager
#Code by: First

# AudioManager is a singleton audio player that plays
# background music and sound effects. The main advantage
# is to provide an easier way to play audio from anywhere
# without having to attach a sound effect to a node. Ex: An
# enemy carrying sound effect that plays when dies. That
# would become frustrated to handle by keeping enemy stay
# alive until the sound finishes playing to prevent sound
# effect getting killed.

# A background music can also be played here. No more than
# 2 background musics are played at the same time.

 ### USAGE ###
# To add a new sound effect, add a child node 'AudioStreamPlayer'
# and place it anywhere you like.
# Once added, load a sound file (*.wav) to a property of
# 'Stream'.
# After a sound file is loaded, add a new variable:
#    For Ex: You've added a new node of AudioStreamPlayer
#            named 'Sfx_Explosion' and loaded a file named
#            'explosion.wav', you might want to add
#            variable in this script to make it appear
#            when using auto-completion from User_AudioManager.
#            Variable should follow the pattern:
#            onready var sfx_explosion : AudioStreamPlayer = $SFX/Sfx_Explosion
# After variable is added, you can now call User_AudioManager
# follow by name of a sound effect. Here's an example how
# to use from other node:
#----------------------------------------
# func _ready():
#     User_AudioManager.sfx_explosion.play()
#----------------------------------------
# Don't worry. play() function will automatically appear
# as auto-completion after you've typed the variable name.
#
#
# To play a background music, call User_AudioManager
# and play_bgn function. Ex:
#
#    User_AudioManager.play_bgm(bgm)
#
# NOTE: bgm must be object of AudioStreamOGGVorbis.
# There's no need to add Background music node here.
# The file can be loaded and sent into here directly.

# This is Auto-loaded scene and script file. Please add
# the scene file of User_AudioManager as AutoLoad in
# the project setting.
# When added, please rename 'AudioManager' class name
# to 'User_AudioManager' to avoid confusion with
# built-in classes.

# PROs:
# - Can be called directly as User_AudioManager.sfx_yoursfxname
#   without having to add a AudioStreamPlayer node or
#   AudioStreamPlayer2D or AudioStreamPlayer3D anywhere.
# - Sound file is played here without getting process
#   killed. Even when changing scene, it won't go anywhere.
# - A single sound effect will never go duplicated.
#   In short ex, playing jump sound will reset itself
#   while playing.
# - Playing the same background music again will not
#   restart the current music. This is useful if you
#   want the current music keeps playing while switching
#   to another scene, etc.
# - Auto-completion for each sound variable also brings
#   up available functions for AudioStreamPlayer's object.
#   This ensures that the script will work when called
#   and no error will occured.
# CONs:
# - Takes more time to setup sound on User_AudioManager. This
#   includes: Creating node > Assign a sound file > and
#   creating a variable to make it work. 3 steps trouble
#   at the cost making it easier to play an audio here.
# - Fading BGM in and out is still buggy. It may get
#   muted completely or randomly resetting the volume.
# - There's no other easier way to restart current bgm
#   while it's being played unless you call stop_bgm()
#   and then play_bgm() again.
# - Calling User_AudioManager.sfx_yoursfx.stop() while
#   it is being stopped can crashes the game and
#   cause Socket Error: 10054. It's best avoid using
#   stop() on sound effects.
# - Playing bgm by passing AudioStreamOGGVorbis to a
#   function can increase RAM.

extends Node

signal bgm_just_started(bgm_name)

#BGM (Background Music)
onready var bgm_core : AudioStreamPlayer = $BGM/BgmCore_DONT_TOUCH_THIS
onready var bgm_property_setter_player : AnimationPlayer = $BGM/BgmCore_DONT_TOUCH_THIS/PropertySetterPlayer

#Sfx (Sound Effects)
onready var sfx_character_enemy_collapse : AudioStreamPlayer = $SFX/Character/Sfx_EnemyCollapse
onready var sfx_character_enemy_damage : AudioStreamPlayer = $SFX/Character/Sfx_EnemyDamage
onready var sfx_character_player_damage : AudioStreamPlayer = $SFX/Character/Sfx_PlayerDamage
onready var sfx_character_player_die : AudioStreamPlayer = $SFX/Character/Sfx_PlayerDie
onready var sfx_character_land : AudioStreamPlayer = $SFX/Character/Sfx_Land

onready var sfx_collectibles_coin : AudioStreamPlayer = $SFX/Collectibles/Sfx_Coin
onready var sfx_collectibles_diamond : AudioStreamPlayer = $SFX/Collectibles/Sfx_Diamond
onready var sfx_collectibles_item : AudioStreamPlayer = $SFX/Collectibles/Sfx_Item

onready var sfx_combat_ballade_cracker_bomb : AudioStreamPlayer = $SFX/Combat/Sfx_BalladeCrackerBomb
onready var sfx_combat_buster : AudioStreamPlayer = $SFX/Combat/Sfx_Buster
onready var sfx_combat_buster_fullycharged : AudioStreamPlayer = $SFX/Combat/Sfx_BusterFullyCharged
onready var sfx_combat_buster_minicharged : AudioStreamPlayer = $SFX/Combat/Sfx_BusterMiniCharged
onready var sfx_combat_buster_charging : AudioStreamPlayer = $SFX/Combat/Sfx_BusterCharging
onready var sfx_combat_diarn_sp_shot : AudioStreamPlayer = $SFX/Combat/Sfx_DiarnSPShot
onready var sfx_combat_ice_break : AudioStreamPlayer = $SFX/Combat/Sfx_IceBreak
onready var sfx_combat_ice_make : AudioStreamPlayer = $SFX/Combat/Sfx_IceMake
onready var sfx_combat_large_explosion : AudioStreamPlayer = $SFX/Combat/Sfx_LargeExplosion
onready var sfx_combat_power_fall : AudioStreamPlayer = $SFX/Combat/Sfx_PowerFall
onready var sfx_combat_power_landing : AudioStreamPlayer = $SFX/Combat/Sfx_PowerLanding
onready var sfx_combat_power_launch : AudioStreamPlayer = $SFX/Combat/Sfx_PowerLaunch
onready var sfx_combat_reflect : AudioStreamPlayer = $SFX/Combat/Sfx_Reflect
onready var sfx_combat_shot : AudioStreamPlayer = $SFX/Combat/Sfx_Shot

onready var sfx_env_boss_door : AudioStreamPlayer = $SFX/Environments/Sfx_BossDoor
onready var sfx_env_coin_landing : AudioStreamPlayer = $SFX/Environments/Sfx_CoinLanding
onready var sfx_env_diamond_landing : AudioStreamPlayer = $SFX/Environments/Sfx_DiamondLanding
onready var sfx_env_enter_door : AudioStreamPlayer = $SFX/Environments/Sfx_EnterDoor
onready var sfx_env_fan : AudioStreamPlayer = $SFX/Environments/Sfx_Fan

onready var sfx_ui_boss_fill_hp : AudioStreamPlayer = $SFX/UI/Sfx_BossFillHp
onready var sfx_ui_game_start : AudioStreamPlayer = $SFX/UI/Sfx_GameStart
onready var sfx_ui_level_up : AudioStreamPlayer = $SFX/UI/Sfx_LevelUp

onready var sfx_unc_serious_damage : AudioStreamPlayer = $SFX/Uncategorized/Sfx_SeriousDamage


var current_bgm : String #Path

#Call by Level.
func play_bgm(var what_bgm : AudioStreamOGGVorbis):
	if what_bgm == null:
		return
	
	var new_bgm_path : String = what_bgm.get_path()
	
	if new_bgm_path != current_bgm:
		bgm_core.volume_db = 0
		bgm_core.set_stream(what_bgm)
		bgm_core.play()
		current_bgm = new_bgm_path
		emit_signal("bgm_just_started", what_bgm.get_path().replace("res://Audio/Bgm/", "").replace(".ogg", ""))

func stop_bgm():
	bgm_core.stop()
	current_bgm = ""

func dim_bgm():
	bgm_property_setter_player.play("Dim")

func undim_bgm():
	bgm_property_setter_player.play("Undim")

func fade_out_bgm(var stop_bgm_after_faded : bool = false):
	if stop_bgm_after_faded:
		bgm_property_setter_player.play("FadeOutStop")
	else:
		bgm_property_setter_player.play("FadeOutNoStop")