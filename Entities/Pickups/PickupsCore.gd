# Pickups

extends KinematicBody2D

class_name Pickups

#-------------------------------------------------
#      Classes
#-------------------------------------------------

#-------------------------------------------------
#      Signals
#-------------------------------------------------

signal collected_by_player(player_obj)
signal collected

#-------------------------------------------------
#      Constants
#-------------------------------------------------

const INITIAL_VELOCITY = Vector2(0, -180)

#-------------------------------------------------
#      Properties
#-------------------------------------------------

#For use with obj spawner
export (Texture) var sprite_preview_texture

#เก็บได้ไหม ถ้า true แปลว่าเก็บได้
export (bool) var grabable = true

#พลังกระดอนขึ้นจากพื้น เลขต่ำกว่า 1.0 จะทำให้กระดอนเบาลง
#ในขณะที่เลขมากกว่า 1.0 จะทำให้ยิ่งกระดอนสูงขึ้น แนะนำให้อยู่ที่ประมาณ 0.5
export (float) var bouncing_power = 0.5

#When false, overrides disappear and blinkstart timers, which
#makes it stay persistent.
#In short. The item will never disappear.
export (bool) var can_disappear = true


onready var pf_bhv = $PlatformBehavior

onready var disappear_ani = $DisappearAnimation

onready var blink_start_timer = $BlinkStartTimer

onready var disappear_timer = $DisappearTimer

onready var collected_delete_delay_timer = $CollectedDeleteDelayTimer


var is_collected = false

#-------------------------------------------------
#      Notifications
#-------------------------------------------------

func _ready() -> void:
	pf_bhv.velocity = INITIAL_VELOCITY
	_can_disappear_check()

#-------------------------------------------------
#      Virtual Methods
#-------------------------------------------------

func _collected_by_player():
	pass

#-------------------------------------------------
#      Override Methods
#-------------------------------------------------

#-------------------------------------------------
#      Public Methods
#-------------------------------------------------

#Cause pickups to bounce by current velocity.
#ทำให้ Pickups กระดอนโดยอิง velocity ปัจจุบัน
func bounce_up() -> void:
	pf_bhv.velocity.y = -pf_bhv.get_velocity_before_move_and_slide().y * bouncing_power

#-------------------------------------------------
#      Connections
#-------------------------------------------------

#Connected from CollectArea2D.
#เช็คว่าเก็บไปโดยผู้เล่นจริงๆหรือไม่
#ถ้าเก็บไปแล้วให้ตรวจสอบว่าเป็น pickup ชนิดไหน
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

#เมื่อเวลาของ blink start timer หมดก็จะทำให้ pickup กระพริบ
#เพื่อแสดงว่ากำลังจะหายไปในเร็วๆนี้
func _on_BlinkStartTimer_timeout():
	disappear_ani.play("Disappearing")

#เมื่อเวลาของ disappear หมดก็จะทำให้ pickup หายไปจาก
#Scene tree ทันที
func _on_DisappearTimer_timeout():
	queue_free()

#เมื่อ platform ได้ลงถึงพื้น
func _on_PlatformBehavior_landed() -> void:
	bounce_up()

func _on_CollectedDeleteDelayTimer_timeout() -> void:
	#Start collect action.
	_collect_action()

#-------------------------------------------------
#      Private Methods
#-------------------------------------------------

#เมธอด collect หรือเรียกโดยง่ายว่า เก็บ
#เรียกอัตโนมัติเมื่อใดที่ผู้เล่นเข้ามาชนกับ collect area
func _collect_action():
	
	queue_free()

#Determined by can_disappear
func _can_disappear_check():
	if not can_disappear:
		pf_bhv.INITIAL_STATE = false
	else:
		blink_start_timer.start()
		disappear_timer.start()

#-------------------------------------------------
#      Setters & Getters
#-------------------------------------------------






