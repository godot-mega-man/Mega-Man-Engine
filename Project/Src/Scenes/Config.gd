extends Node


export var bgm : AudioStreamOGGVorbis


var cursor_position : int


func _ready() -> void:
	FJ_AudioManager.play_bgm(bgm)


func _on_ConfigMenuList_confirmed() -> void:
	$FadeScreen.go_to_scene("res://Src/Scenes/Title.tscn")
