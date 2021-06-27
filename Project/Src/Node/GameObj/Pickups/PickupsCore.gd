# Pickups

class_name Pickups extends KinematicBody2D


signal collected_by_player(player_obj)

signal collected


const INITIAL_VELOCITY = Vector2(0, -180)


#For use with obj spawner
export (Texture) var sprite_preview_texture

export (bool) var grabable = true

export (float) var bouncing_power = 0.5

export (bool) var can_disappear = true


onready var pf_bhv = $PlatformBehavior

onready var disappear_ani = $DisappearAnimation

onready var blink_start_timer = $BlinkStartTimer

onready var disappear_timer = $DisappearTimer

onready var collected_delete_delay_timer = $CollectedDeleteDelayTimer


var is_collected = false


func _ready() -> void:
	pf_bhv.velocity = INITIAL_VELOCITY
	_can_disappear_check()


func _collected_by_player():
	pass


#Cause pickups to bounce by current velocity.
func bounce_up() -> void:
	pf_bhv.velocity.y = -pf_bhv.get_velocity_before_move_and_slide().y * bouncing_power


func _collect_action():
	queue_free()


func _can_disappear_check():
	if not can_disappear:
		pf_bhv.INITIAL_STATE = false
	else:
		blink_start_timer.start()
		disappear_timer.start()


# Connected from CollectArea2D.
func _on_CollectArea2D_area_entered(area):
	if is_collected:
		return
	
	var player = area.get_owner() #Assuming it's player.
	
	if player is Player and grabable:
		emit_signal("collected_by_player", player)
		emit_signal("collected")
		
		#Call virtual method. 
		_collected_by_player()
		
		#Start deletion bomb (Timer).
		collected_delete_delay_timer.start()
		
		is_collected = true


func _on_BlinkStartTimer_timeout():
	disappear_ani.play("Disappearing")


func _on_DisappearTimer_timeout():
	queue_free()


func _on_PlatformBehavior_landed() -> void:
	bounce_up()


func _on_CollectedDeleteDelayTimer_timeout() -> void:
	_collect_action()

