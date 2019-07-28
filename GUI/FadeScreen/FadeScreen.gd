extends CanvasLayer
class_name FadeScreen

signal changing_scene
signal fading_finished
signal fading_started

#Child nodes
onready var fade_player = $Control/FadePlayer

var scene_to_go : String
var is_reload_scene_call = false

func go_to_scene(var target : String):
	scene_to_go = target
	fade_player.play("Fade Out")
	get_tree().paused = true
	print('Preloading scene: ' + target)
	
	emit_signal("changing_scene")

func reload_scene():
	fade_player.play("Fade Out")
	get_tree().paused = true
	is_reload_scene_call = true #To let fader know we're reloading scene
	print('Reloading scene: ' + str(get_tree().current_scene.get_path()))
	
	emit_signal("changing_scene")

func _on_AnimationPlayer_animation_finished(anim_name : String):
	if anim_name == "Fade Out":
		#Choose between go_to_scene or reloading current
		if is_reload_scene_call:
			get_tree().reload_current_scene()
		else:
			get_tree().change_scene(scene_to_go)
	if anim_name == "Fade In":
		get_tree().paused = false
	
	emit_signal("fading_finished")

func _on_AnimationPlayer_animation_started(anim_name : String):
	if anim_name == "Fade In":
		get_tree().paused = true
	
	emit_signal("fading_started")