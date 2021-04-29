extends Node


func next_scene():
	$FadeScreen.go_to_scene("res://Src/Scenes/Title.tscn")


func _on_NextSceneTimer_timeout() -> void:
	next_scene()


func _on_InputActionCallback_just_pressed(action) -> void:
	next_scene()
