extends Node


export var bgm : AudioStreamOGGVorbis


var cursor_position : int


func _ready() -> void:
	Audio.play_bgm(bgm)


func initiate_games():
	GameResetter.reset()
	Life.starting_lives = Difficulty.get_lives_by_current_difficulty()
	Life.reset()


func _on_TitleMainMenuList_entering_start() -> void:
	$Control/UiAnim.play("ToDifficulty")
	$Control/TitleMainMenuList.disabled = true
	$Control/TitleDifficultyMenuList.disabled = false


func _on_TitleMainMenuList_entering_config() -> void:
	$FadeScreen.go_to_scene("res://Src/Scenes/Config.tscn")


func _on_TitleMainMenuList_entering_exit() -> void:
	$FadeScreen.fade_player.play("Fade Out")
	yield($FadeScreen.fade_player, "animation_finished")
	get_tree().quit()


func _on_TitleDifficultyMenuList_difficulty_selected(level) -> void:
	Difficulty.difficulty = level
	initiate_games()
	$FadeScreen.go_to_scene("res://Src/Scenes/Levels/Showcase.tscn")


func _on_TitleDifficultyMenuList_canceled() -> void:
	$Control/UiAnim.play("ToMain")
	$Control/TitleDifficultyMenuList.set_deferred("disabled", true)
	$Control/TitleMainMenuList.set_deferred("disabled", false)
