extends CanvasLayer


const BGM_VICTORY_NEWCOMER = preload("res://Assets/Sounds/Bgm/weapon_get2.ogg")
const BGM_VICTORY_CASUAL = preload("res://Assets/Sounds/Bgm/weapon_get.ogg")


export var next_scene = "res://Src/Scenes/Disclaimer.tscn"


var going_next_scene : bool


func _ready() -> void:
	GameHUD.hide_all()
	get_tree().paused = false
	$Control/ClearTime/Time.text = Playtime.get_playtime_string()
	_update_difficulty_hint()
	
	if Difficulty.difficulty == Difficulty.DIFF_NEWCOMER:
		$Bgm.stream = BGM_VICTORY_NEWCOMER
		$Control/ClearTime/Time/FlashingAnim.play("No Flash")
		$Control/Bg2.color = Color.black
	else:
		$Bgm.stream = BGM_VICTORY_CASUAL
		$Control/ClearTime/Time/FlashingAnim.play("Flash")
	
	$Bgm.play()


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		try_go_next_scene()


func try_go_next_scene():
	if $MainAnim.is_playing():
		return
	if going_next_scene:
		return
	
	going_next_scene = true
	
	$FadeAnim.play("Fade")
	yield($FadeAnim, "animation_finished")
	get_tree().change_scene("res://Src/Scenes/Disclaimer.tscn")


func _update_difficulty_hint():
	var next_diff : String = ""
	
	if Difficulty.difficulty == Difficulty.DIFF_NEWCOMER:
		next_diff = Difficulty.DIFFNAME_CASUAL
	if Difficulty.difficulty == Difficulty.DIFF_CASUAL:
		next_diff = Difficulty.DIFFNAME_NORMAL
	if Difficulty.difficulty == Difficulty.DIFF_NORMAL:
		next_diff = Difficulty.DIFFNAME_SUPERHERO
	if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
		$Control/ClearTime/DiffHint.text = "You are Super Player!"
		return
	
	$Control/ClearTime/DiffHint.text = str(
		"Try ",
		next_diff,
		" difficulty!"
	)
