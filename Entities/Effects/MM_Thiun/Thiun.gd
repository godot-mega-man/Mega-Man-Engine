extends Sprite

func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()