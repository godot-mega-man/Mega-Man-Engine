extends Control

#Child nodes
onready var fade_screen = $FadeScreen

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "AutoPlay":
		fade_screen.go_to_scene("res://DEV_ExampleUsages/Ex_LevelCreationTest/MegaMan_Level/Level.tscn")
