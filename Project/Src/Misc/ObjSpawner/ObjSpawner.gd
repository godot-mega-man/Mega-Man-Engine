# Object Spawner
# 
# This node is mainly for spawning object within the level scene
# by various events. This usually used in many levels for object
# placements, such as: Enemy, Falling Block, Minions Spawner, etc.


tool
extends Node2D


signal spawned(inst_obj)


#Obj to spawn. This can be any .tscn file.
export (PackedScene) var obj_spawn setget set_obj_spawn

#Spawn on by events. If 'Time Out' is checked, the object will spawn
#when the timer is up. If 'Screen Entered' is checked, the object
#will spawn whenever this node is entered screen.
export (int, FLAGS, "Time Out", "Screen Entered") var spawn_on

#Spawn interval in seconds for the object to spawn. Spawn on time out
#must be on, otherwise this will have no effect.
export (float) var spawn_interval = 3 setget set_spawn_interval

#One shot for spawn_interval. If enabled, the object will spawn only
#once and timer will stop. Which you'll have to start timer manually
#through code.
export (bool) var one_shot = false setget set_one_shot

#Starts timer automatically as soon as the scene begin when on.
export (bool) var autostart = false setget set_autostart

#Number of objects that can exist in the scene tree. Set to -1 for
#unlimited and prepare to handle the memory limits by yourself.
export (int, -1, 65535) var obj_exist_limit = -1

#When on, object won't spawn outside screen.
export (bool) var activate_only_on_screen = true

#Better not touch this unless you know what you're doing.
export (NodePath) var spawn_target_node = "./../"

#Spawn range in size of rectangle extents by pixel.
export (float) var spawn_range = 8 setget set_spawn_range

#When on, the object will highlight itself.
#This only work in editor!
export (bool) var debug_highlight = false setget set_debug_highlight

#Define custom parameter for a spawned object here.
#This contains key and value that sets variable name and value
#respectively.
#In case you're setting object's variables (EnemyCore for ex.),
#be sure to check all available variables that the object offers.
export (Dictionary) var custom_parameters : Dictionary

#Deletes obj count on this node when a spawned object emits a signal
#by name. Useful when you want make an object deleted permanently.
export (Array, String) var obj_deletion_by_signals : Array


export (int, FLAGS, "Newcomer", "Casual", "Normal", "Superhero") var difficulty_exclude


onready var spawn_range_vis = $PreciseVisibilityNotifier2D

onready var spawn_timer = $SpawnTimer as Timer

onready var sprite_preview = $SpritePreview as Sprite

onready var level := get_node_or_null("/root/Level") as Level


var my_obj_count : int = 0


func set_obj_spawn(var new_value : PackedScene):
	obj_spawn = new_value
	
	_update_sprite_preview()


func set_debug_highlight(var new_value):
	debug_highlight = new_value
	
	if !Engine.is_editor_hint():
		return
	if get_node_or_null("DebugVisualHighlighter") != null:
		if debug_highlight:
			get_node("DebugVisualHighlighter").play("Highlight")
		else:
			get_node("DebugVisualHighlighter").stop()


func set_spawn_interval(var new_value):
	spawn_interval = clamp(new_value, 0.001, INF)
	
	if get_node_or_null("SpawnTimer") != null:
		get_node("SpawnTimer").wait_time = new_value


func set_one_shot(var new_value):
	one_shot = new_value
	
	if get_node_or_null("SpawnTimer") != null:
		get_node("SpawnTimer").one_shot = new_value


func set_autostart(var new_value):
	autostart = new_value
	
	if get_node_or_null("SpawnTimer") != null:
		get_node("SpawnTimer").autostart = new_value


func set_spawn_range(var new_value):
	spawn_range = new_value
	
	if get_node_or_null("SpawnRange") != null:
		var rect_centralizer = RectCentralizer.new()
		var centralized_rect_value : Rect2
		centralized_rect_value = rect_centralizer.center_rect_by_value(new_value)
		get_node("SpawnRange").rect = centralized_rect_value
		get_node("SpawnRange").position = -centralized_rect_value.size


func _ready():
	spawn_range_vis.detection_box_size = Vector2(spawn_range, spawn_range)
	_update_sprite_preview()


#Update sprite texture preview.
#Usually happens when a packed scene (obj_spawn) is set.
func _update_sprite_preview():
	#Get texture according to the current obj_spawn.
	if obj_spawn != null:
		var inst_object = obj_spawn.instance()
		if inst_object is EnemyCore:
			if get_node_or_null("SpritePreview") != null:
				get_node("SpritePreview").texture = inst_object.sprite_preview_texture
		if inst_object is Pickups:
			if get_node_or_null("SpritePreview") != null:
				get_node("SpritePreview").texture = inst_object.sprite_preview_texture
		
		inst_object.queue_free()


#This will immediately instance a packed scene and add child.
func spawn_object(var check : bool = true):
	#If obj_spawn is null, do nothing!
	if obj_spawn == null:
		return
	
	#If the object can only spawn on active screen,
	#checks whether this spawner is on screen.
	if activate_only_on_screen and !spawn_range_vis.is_inside_visible_viewport_rect():
		return
	
	#If the obj is being spawned, check if it exceeds limit.
	if obj_exist_limit != -1 and my_obj_count >= obj_exist_limit:
		return
	
	# Check if the spawner excluded from spawning in the current difficulty
	if BitFlagsComparator.is_bit_enabled(difficulty_exclude, Difficulty.difficulty):
		return
	
	#Before spawning, make sure the screen transition is not active.
	#If screen is transiting, this object will wait until it's completed.
	if level.is_screen_transiting:
		return
	
	
	var obj_inst = obj_spawn.instance()
	
	if get_node_or_null(spawn_target_node) != null:
		if obj_inst is Node2D:
			obj_inst.global_position = self.global_position
		
		#Set custom parameters for obj_inst (if any..).
		_set_custom_parameters(obj_inst)
		
		get_node(spawn_target_node).add_child(obj_inst)
		
		#Connect to spawned obj to notify me if you were destroyed.
		if !obj_inst.is_connected("tree_exited", self, "_on_my_spawned_obj_exited"):
			obj_inst.connect("tree_exited", self, "_on_my_spawned_obj_exited")
		
		#Connect to spawned obj to notify me if you were destroyed
		#to decrease object count.
		for i in obj_deletion_by_signals:
			i = i as String
			if not obj_inst.is_connected(i, self, "_on_obj_emitted_signal_for_deletion"):
				obj_inst.connect(i, self, "_on_obj_emitted_signal_for_deletion")
		
		emit_signal("spawned", obj_inst)
		
		my_obj_count += 1


#Check whether spawned object still exists.
func is_my_obj_exist() -> bool:
	return bool(my_obj_count)


#Set parameters for obj.
func _set_custom_parameters(var obj : Object):
	if Engine.is_editor_hint():
		return
	
	if custom_parameters.size() == 0:
		return
	var idx = 0
	for i in custom_parameters.keys():
		obj.set(i, custom_parameters.values()[idx])
		idx += 1


#Connect from signalings--------------------------
func _on_SpawnTimer_timeout():
	if get_node("/root/BitFlagsComparator").is_bit_enabled(spawn_on, 0):
		spawn_object()


func _on_PreciseVisibilityNotifier2D_visibility_entered() -> void:
	if get_node("/root/BitFlagsComparator").is_bit_enabled(spawn_on, 1):
		spawn_object()


func _on_my_spawned_obj_exited():
	my_obj_count -= 1


func _on_obj_emitted_signal_for_deletion():
	my_obj_count += 1
