extends Control

signal death_gui_just_appeared
signal respawn_btn_pressed
signal to_village_btn_pressed

const TO_VILLAGE_TEXT = "To Village"
const TO_VILLAGE_CONFIRMATION_TEXT = "CONFIRM?"

#Child nodes
onready var animation_player = $AnimationPlayer
onready var gold_lost_text = $VBoxContainer/HB_CoinLostContainer/GoldLostText
onready var gold_lost_text_tween = $VBoxContainer/HB_CoinLostContainer/GoldLostText/Tween
onready var gold_minus_text = $VBoxContainer/HB_CoinLostContainer/GoldMinusText
onready var exp_lost_text = $VBoxContainer/HB_ExpLostContainer/ExpLostText
onready var exp_lost_text_tween = $VBoxContainer/HB_ExpLostContainer/ExpLostText/Tween
onready var exp_minus_text = $VBoxContainer/HB_ExpLostContainer/ExpMinusText
onready var remaining_gold_text = $VRemainingContainer/GoldRemainingContainer/GoldLabel
onready var remaining_gold_text_tween = $VRemainingContainer/GoldRemainingContainer/GoldLabel/Tween
onready var remaining_exp_text = $VRemainingContainer/ExpRemainingContainer/ExpLabel
onready var remaining_exp_text_tween = $VRemainingContainer/ExpRemainingContainer/ExpLabel/Tween
onready var remaining_exp_next_text = $VRemainingContainer/ExpRemainingContainer/ExpNextLabel
onready var revive_button_ads = $VBoxContainer2/ReviveButtonAds
onready var revive_button_village = $VBoxContainer2/ReviveButton2
onready var confirm_timer = $VBoxContainer2/ReviveButton2/ConfirmTimer

onready var currency_manager = $"/root/CurrencyManager"
onready var player_stats = $"/root/PlayerStats"

#Temp
var temp_signaling_name : String 
var is_gold_exp_lost_tweened : bool = false

func start_death_gui():
	animation_player.play("Appear")
	emit_signal("death_gui_just_appeared")
	
	#Init remaining text of current gold and exp
	#To demonstate how much your gold and exp remains.
	remaining_gold_text.init_and_tween(currency_manager.game_coin + currency_manager.coin_lost)
	remaining_exp_text.init_and_tween(player_stats.experience_point + player_stats.exp_lost)
	remaining_exp_next_text.text = str(player_stats.experience_point_next)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Appear":
		animation_player.play("ShowCoinExpLost")
	if anim_name == "ShowCoinExpLost":
		var gold_lost_amount = currency_manager.coin_lost
		var exp_lost_amount = player_stats.exp_lost
		var current_coin = currency_manager.game_coin
		var current_exp = player_stats.experience_point
		gold_lost_text.init_and_tween(gold_lost_amount)
		exp_lost_text.init_and_tween(exp_lost_amount)
		remaining_gold_text.init_and_tween(current_coin)
		remaining_exp_text.init_and_tween(current_exp)
		
		#Set temp variable if gold and exp is lost.
		var is_gold_lost : bool = gold_lost_amount > 0
		var is_exp_lost : bool = exp_lost_amount > 0
		#Set text color to red and show minus text.
		if is_gold_lost:
			gold_lost_text.add_color_override("font_color", Color("fb3800"))
			gold_minus_text.visible = true
		if is_exp_lost:
			exp_lost_text.add_color_override("font_color", Color("fb3800"))
			exp_minus_text.visible = true
		#Play gold exp lost sfx
		if is_gold_lost or is_exp_lost:
			FJ_AudioManager.sfx_gold_exp_lost.play()
		else:
			revive_button_ads.visible = false
	if anim_name == "HideAll":
		emit_signal(temp_signaling_name)

#On tween completed, start showing buttons
func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	if not is_gold_exp_lost_tweened:
		animation_player.play("ShowButtons")
		is_gold_exp_lost_tweened = true

#Revive at Checkpoint
func _on_ReviveButton_pressed() -> void:
	animation_player.play("HideAll")
	temp_signaling_name = "respawn_btn_pressed"

#Revive at nearest Village
#This button requires the player to confirm that
#it is not accidentally pressed by having to tap
#this button two times.
func _on_ReviveButton2_pressed() -> void:
	if not revive_button_village.text == TO_VILLAGE_CONFIRMATION_TEXT:
		revive_button_village.text = TO_VILLAGE_CONFIRMATION_TEXT
		confirm_timer.start()
	else:
		temp_signaling_name = "to_village_btn_pressed"
		animation_player.play("HideAll")

#On confirm timer timeout, reset confirm button so
#the player will have to tap that button twice again.
func _on_ConfirmTimer_timeout() -> void:
	revive_button_village.text = TO_VILLAGE_TEXT

func _on_ReviveButtonAds_pressed():
	recover_all_lost_gold_and_exp()

func recover_all_lost_gold_and_exp():
	var coin_recover_amount : int = currency_manager.coin_lost
	var exp_recover_amount : int = player_stats.exp_lost
	var new_coin = currency_manager.game_coin + coin_recover_amount
	var new_exp = player_stats.experience_point + exp_recover_amount
	
	currency_manager.game_coin = new_coin
	currency_manager.clean_up_lost_coin()
	player_stats.experience_point = new_exp
	player_stats.clean_up_lost_exp()
	
	gold_lost_text.init_and_tween(0)
	exp_lost_text.init_and_tween(0)
	gold_lost_text.add_color_override('font_color', Color('ffffff'))
	exp_lost_text.add_color_override('font_color', Color('ffffff'))
	remaining_gold_text.init_and_tween(new_coin)
	remaining_exp_text.init_and_tween(new_exp)
	
	gold_minus_text.visible = false
	exp_minus_text.visible = false
	
	revive_button_ads.text = "Recovered"
	revive_button_ads.disabled = true
	
	#Play recover sfx
	FJ_AudioManager.sfx_gold_exp_recover.play()
