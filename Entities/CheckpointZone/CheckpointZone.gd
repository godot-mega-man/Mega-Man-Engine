# - CheckpointZone -
# 
# ---------------
# Code by : First
# ---------------
#
#  Checkpoint Zone are points where a game will automatically
# save your progress and restart the player upon death.
# As such, the player does not need to restart the entire level
# over again. This reduces the frustration and tedium 
# that is potentially felt without such a design.
#
#  HOW IT WORK?
#  Once the player interacts with this object, the checkpoint
# zone will update and set respawn location to most recent
# according to CheckpointSpawnLocation's position. These are
# following properties that you can set:
# @export.param 'checkpoint_priority' : This value will be used
#   to determine how checkpoint works. Default value is 0.
#   Higher priority value will update and replace old one.
#   note that if priority value you set is lower than the most
#   recent checked point, this object won't update checkpoint.
# @export.param 'ignore_priority' : This will completely ignores
#   checkpoint's priority no matter what value of priority is.
#
#  HOW TO USE?
#  Place this object into editor. This can be used anywhere
# within scene tree. Set checkpoint's priority if needed.
# 
#  CUSTOM CHECKPOINT SPAWN LOCATION
#  Right click on the object in scene tab and turn on
# 'Editable Children'. You'll then be able to move its spawn
# location anywhere within the scene.

extends ReferenceRect

export (int) var checkpoint_priority = 0
export (bool) var ignore_priority = false
export (NodePath) var target_view

#Child nodes
onready var label = $Label
onready var checkpoint_spawn_position = $CheckpointSpawnPositon
onready var spawn_point_label = $CheckpointSpawnPositon/SpawnPointLabel

var spawn_offset := Vector2(0, -1)

func _ready():
	label.queue_free()
	spawn_point_label.queue_free()

func _on_AreaNotifier_entered_area() -> void:
	update_checkpoint()

func update_checkpoint():
	var update_position
	var current_scene = get_tree().get_current_scene().get_filename()
	
	update_position = checkpoint_spawn_position.get_global_position() + checkpoint_spawn_position.rect_pivot_offset + spawn_offset
	
	CheckpointManager.update_checkpoint_position(update_position, current_scene, get_node(target_view).name, ignore_priority, checkpoint_priority)
	
	if target_view == null:
		push_warning(str(self.get_path(), ": Target new is not specified. Default value will be used."))
