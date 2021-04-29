extends Node


func _ready() -> void:
	GameHUD.hide_all()
	GameResetter.reset()


func retry():
	$FadeScreen.go_to_scene("res://Src/Scenes/Levels/Showcase.tscn")


func to_title():
	$FadeScreen.go_to_scene("res://Src/Scenes/Title.tscn")


func _on_GameOverMenuList_selected(id) -> void:
	if id == 0:
		retry()
	if id == 1:
		to_title()
