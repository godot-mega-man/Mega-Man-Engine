#CoinCore
#Code by: First

#THE COIN/ITEM EMULATED USING REAL PHYSICS. 
#HIGH CPU INTENSE. NEED TO BE IMPROVED

extends KinematicBody2D
class_name CoinCore

enum preset_item_type {
	COIN
}

enum preset_landing_sfxes {
	COIN
}

enum preset_collect_sfxes {
	COIN
}

export (preset_item_type) var ITEM_TYPE
export (int) var COIN_VALUE = 1
export (float) var DESTROY_TIME_DELAY = 8.0
export (float) var DESTROY_TIME = 3.0
export (bool) var STAY_FOREVER = false
export (bool) var CREATE_COIN_LANDING_EFFECT = true
export (preset_landing_sfxes) var LANDING_SFX = preset_landing_sfxes.COIN
export (preset_collect_sfxes) var COLLECT_SFX = preset_landing_sfxes.COIN
export (float) var COLLECT_READY_TIME = 0.4
export (bool) var DESTROY_OUTSIDE_SCREEN = true
export (bool) var APPLY_WARP_AROUND_UPSIDE_DOWN = true

export var GRAVITY = 600
export var MAX_FALL_SPEED = 400
export var BOUNCE_REDUCTION = 0.6
export var MINIMUM_BOUNCE_POWER = 0
export var SWAY_X_RANGE = 60
export var GEYSER_Y_RANGE_MIN = -100
export var GEYSER_Y_RANGE_MAX = -200
export var DAMPING_START_ON_FLOOR = true
export var DAMPING = 40 #Pixels per second

const WARP_OFFSET = 16

#Child nodes
onready var sprite = $Sprite
onready var collision_shape = $CollisionShape2D
onready var destroy_timer = $DestroyTimer
onready var destroy_delay_timer = $DestroyDelayTimer
onready var blinking_player = $BlinkingPlayer
onready var player = get_node("/root/Level/Iterable/Player")
onready var land_pos = $LandPos
onready var collect_ready_timer = $CollectReadyTimer
onready var coin_area = $CoinArea2D
onready var coin_area_collision_shape = coin_area.get_node("CollisionShape2D")
onready var visible_notify = $VisibilityNotifier2D
onready var shrink_and_queue_free_player = $ShrinkAndQueueFreePlayer

onready var audio_manager = get_node("/root/AudioManager")
onready var level = get_node("/root/Level")

#Temp variables
var velocity
var is_landed = false
var is_ready_to_be_collected = false
var item_data_file # From res://Misc/InventoryCore/Items/*.tres
var loaded_item_data_file #From loaded item data file 

onready var is_level_upside_down = level.WARPS_PLAYER_AROUND_UP_DOWN
onready var level_limit_top = level.CAMERA_LIMIT_TOP - WARP_OFFSET
onready var level_limit_bottom = level.CAMERA_LIMIT_BOTTOM + WARP_OFFSET

#Preload
var coin_land_effect = preload("res://Entities/Effects/CoinLandEffect/CoinLandEffect.tscn")
var coin_counter = preload("res://Entities/Effects/AddCoinCounter/CoinCounter1.tscn")
var coin_sparkling_effect = preload("res://Entities/Effects/CoinSparklingEffect/CoinSparklingEffect.tscn")

func _ready():
	add_collision_exception_with(player)
	destroy_delay_timer.connect("timeout", self, "_on_destroy_delay_timer_timeout")
	destroy_timer.connect("timeout", self, "_on_destroy_timer_timeout")
	collect_ready_timer.connect("timeout", self, '_on_collect_ready_timer')
	#Used for exiting screen check
	if DESTROY_OUTSIDE_SCREEN:
		visible_notify.connect("screen_exited", self, '_on_leaving_screen')
	
	#Start timer to activate self-destruct-timer
	if !STAY_FOREVER:
		destroy_delay_timer.start(DESTROY_TIME_DELAY)
	#Start timer to let's player able to collect coin when ready.
	collect_ready_timer.start(COLLECT_READY_TIME)
	
	#Set velocity
	velocity = Vector2(rand_range(-SWAY_X_RANGE, SWAY_X_RANGE), rand_range(GEYSER_Y_RANGE_MIN, GEYSER_Y_RANGE_MAX))

func _physics_process(delta: float) -> void:
	#Apply gravity
	velocity.y += GRAVITY * delta
	#Damping
	if DAMPING_START_ON_FLOOR && is_landed:
		if velocity.x > 0:
			velocity.x += -DAMPING * delta
		else:
			velocity.x -= -DAMPING * delta
	
	#Check max fall speed
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED
	
	#Check if velocity of x-axis is between -1 and 1,
	#set its value of x-axis to 0.
	if velocity.x > -1 and velocity.x < 1:
		velocity.x = 0
	
	#Apply position
	move_and_slide(velocity, Vector2(0, -1))
	
	#Bounce if on floor
	if is_on_floor():
		if velocity.y >= 0: #When falling, bounce
			velocity.y = -velocity.y * BOUNCE_REDUCTION
		if !is_landed:
			is_landed = true
		if velocity.y > -MINIMUM_BOUNCE_POWER:
			velocity.y = -MINIMUM_BOUNCE_POWER
		
		#Create coin landing effect.
		if velocity.y < -80:
			if CREATE_COIN_LANDING_EFFECT:
				var effect = coin_land_effect.instance()
				effect.global_position = self.global_position + (self.land_pos.position + Vector2(rand_range(-4, 4), rand_range(-2, 0)))
				get_parent().add_child(effect)
				
				#Play landing sfx
				play_landing_sfx(LANDING_SFX)
	
	#Bounce if on wall
	if is_on_wall():
		velocity.x = -velocity.x
	
	#Warps coin upside down
	if APPLY_WARP_AROUND_UPSIDE_DOWN:
		#Warps upside down if the level is allowed
		if is_level_upside_down:
			
			if self.global_position.y > level_limit_bottom:
				self.global_position.y = level_limit_top

#When delayed and on time, start timer
func _on_destroy_delay_timer_timeout():
	destroy_timer.start(DESTROY_TIME)
	blinking_player.play("Blinking")

#When timer running out, destroy the coin
func _on_destroy_timer_timeout():
	destroy_coin()

#When collect timer is ready, set enable.
func _on_collect_ready_timer():
	is_ready_to_be_collected = true

func destroy_coin():
	#Disable all collisions and movements.
	collision_shape.disabled = true
	coin_area_collision_shape.disabled = true
	self.set_physics_process(false)
	shrink_and_queue_free_player.play("ShrinkAndQueueFree")

func player_collected_coin():
	#Check whether it is coin or item.
	if is_coin():
		#Create coin counter effect
		var counter = coin_counter.instance()
		counter.global_position = self.global_position
		get_parent().add_child(counter)
		counter.get_node("Label").text = "+" + str(COIN_VALUE) #Set text
		#Set text color
		counter.get_node("Label").add_color_override("font_color", Color("fbba00"))
		#Play floating text animation
		counter.animation_player.play("CoinCounter")
		
		#Call Game-GUI to create collected item tooltip.
		level.game_gui.tooltip_controller.add_collected_item_tooltip("Coin", COIN_VALUE, load('res://Entities/Coin/AnimatedTexture_Coin.tres'))
		level.game_gui.update_coin()
	
	#Create coin counter effect
	var sparkling = coin_sparkling_effect.instance()
	sparkling.global_position = self.global_position
	get_parent().add_child(sparkling)
	
	#Play sound effect
	play_collect_sfx(COLLECT_SFX)
	
	#Delete clone
	destroy_coin()

#Used for exiting screen check
func _on_leaving_screen():
	destroy_coin()

func is_coin():
	return ITEM_TYPE == preset_item_type.COIN

func play_landing_sfx(var what):
	if what == preset_landing_sfxes.COIN:
		audio_manager.sfx_coin_landing.play()

func play_collect_sfx(var what):
	if what == preset_collect_sfxes.COIN:
		audio_manager.sfx_coin.play()