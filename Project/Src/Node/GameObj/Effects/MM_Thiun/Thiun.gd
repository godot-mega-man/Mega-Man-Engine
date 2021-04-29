extends Sprite

func _on_PreciseVisibilityNotifier2D_visibility_exited() -> void:
	queue_free()
