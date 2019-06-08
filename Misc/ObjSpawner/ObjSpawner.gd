tool
extends Node2D

signal spawned(inst_obj)

export (PackedScene) var obj_spawn setget set_obj_spawn
export (int, FLAGS, "Time Out", "Screen Entered") var spawn_on
export (float) var spawn_interval = 3 setget set_spawn_interval
export (bool) var one_shot = false setget set_one_shot
export (bool) var autostart = false setget set_autostart
export (int, -1, 65535) var obj_exist_limit = -1
export (bool) var activate_only_on_screen = true
export (NodePath) var spawn_target_node = "./../"
export (float) var spawn_range = 8 setget set_spawn_range
export (bool) var debug_highlight = false setget set_debug_highlight

#Child nodes
onready var spawn_range_vis = $SpawnRange as VisibilityNotifier2D
onready var spawn_timer = $SpawnTimer as Timer
onready var sprite_preview = $SpritePreview as Sprite

#TEMP variables
var my_obj_count : int = 0

#Getter/Setter
func set_obj_spawn(var new_value):
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


#Ready
func _ready():
	_update_sprite_preview()
	

#Update sprite texture preview.
#Usually happens when a packed scene (obj_spawn) is set.
func _update_sprite_preview():
	#This will clear the sprite's preview texture while not in debug mode...
	if !Engine.is_editor_hint():
		if get_node_or_null("SpritePreview") != null:
			get_node("SpritePreview").texture = null
		return
	
	#Get texture according to the current obj_spawn by finding Sprite node.
	if get_node_or_null("SpritePreview") != null:
		var texture_from_new_value
		get_node("SpritePreview").texture = get_sprite_preview_texture_or_null(obj_spawn)

#Get texture from a sprite node in possible node's names.
#This receives a packed scene and then instance to get a texture
#from a sprite.
#Returns a texture if sprite is found on a node.
func get_sprite_preview_texture_or_null(var packed_scene : PackedScene):
	if packed_scene == null:
		return null
	
	#Lookup on node name within an instanced packed_scene.
	var NODENAME = [
		"SpritePreview",
		"Sprite"
	]
	
	#Loop through NODENAME to find a Sprite node.
	var inst_obj = packed_scene.instance()
	for i in NODENAME:
		var _sprite_node = inst_obj.get_node_or_null(i)
		if _sprite_node != null:
			if _sprite_node is Sprite:
				return _sprite_node.texture
	
	return null

#This will immediately instance a packed scene and add child.
func spawn_object(var check : bool = true):
	var check_passed = true
	if check:
		#If the object can only spawn on active screen,
		#checks whether this spawner is on screen.
		if activate_only_on_screen and !spawn_range_vis.is_on_screen():
			check_passed = false
		#If the obj is being spawned, check if it exceeds limit.
		if obj_exist_limit != -1 and my_obj_count >= obj_exist_limit:
			check_passed = false
	
	if not check_passed:
		return
	
	var obj_inst = obj_spawn.instance()
	
	if get_node_or_null(spawn_target_node) != null:
		if obj_inst is Node2D:
			obj_inst.global_position = self.global_position
		get_node(spawn_target_node).add_child(obj_inst)
		
		#Connect to spawned obj to notify me if you were destroyed.
		if !obj_inst.is_connected("tree_exited", self, "_on_my_spawned_obj_exited"):
			obj_inst.connect("tree_exited", self, "_on_my_spawned_obj_exited")
		
		emit_signal("spawned", obj_inst)
		
		my_obj_count += 1

#Check whether spawned object still exists.
func is_my_obj_exist() -> bool:
	return bool(my_obj_count)

#Connect by signalings--------------------------
func _on_SpawnTimer_timeout():
	var bit_flag_comparator = BitFlagsComparator.new()
	if bit_flag_comparator.is_bit_enabled(spawn_on, 0):
		spawn_object()
func _on_SpawnRange_screen_entered() -> void:
	var bit_flag_comparator = BitFlagsComparator.new()
	if bit_flag_comparator.is_bit_enabled(spawn_on, 1):
		spawn_object()
func _on_my_spawned_obj_exited():
	my_obj_count -= 1