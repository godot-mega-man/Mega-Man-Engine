# CheckpointZone


extends ReferenceRect


export (int) var checkpoint_priority = 0

export (bool) var ignore_priority = false

export (NodePath) var target_view

export (int) var max_difficulty = Difficulty.DIFF_SUPERHERO


onready var label = $Label

onready var checkpoint_spawn_position = $CheckpointSpawnPositon

onready var spawn_point_label = $CheckpointSpawnPositon/SpawnPointLabel


var spawn_offset := Vector2(0, -1)


func _ready():
	label.queue_free()
	spawn_point_label.queue_free()


func update_checkpoint():
	if Difficulty.difficulty > max_difficulty:
		return
	
	var update_position
	var current_scene = get_tree().get_current_scene().get_filename()
	
	update_position = checkpoint_spawn_position.get_global_position() + checkpoint_spawn_position.rect_pivot_offset + spawn_offset
	
	CheckpointManager.update_checkpoint_position(update_position, current_scene, get_node(target_view).name, ignore_priority, checkpoint_priority)
	
	if target_view == null:
		push_warning(str(self.get_path(), ": Target new is not specified. Default value will be used."))


func _on_AreaNotifier_entered_area() -> void:
	update_checkpoint()
