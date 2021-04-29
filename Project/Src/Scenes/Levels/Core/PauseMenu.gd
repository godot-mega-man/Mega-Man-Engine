extends CanvasLayer


signal menu_hidden
signal menu_enclosed


func show_pause_menu():
	$Anim.play("Show")
	yield($Anim, "animation_finished")
	$Control/LevelPauseMenuList.init()
	$Control/LevelPauseMenuList.disabled = false


func enclose_pause_menu():
	$Control/LevelPauseMenuList.disabled = true
	$Anim.play("Hide")
	yield($Anim, "animation_finished")
	emit_signal("menu_enclosed")


func hide_pause_menu():
	$Control/LevelPauseMenuList.disabled = true
	$Anim.play("Resume")
	yield($Anim, "animation_finished")
	emit_signal("menu_hidden")
