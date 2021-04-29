extends Node2D

onready var origin_position = self.global_position
export var offset = Vector2(0, 0)

#Child nodes
onready var animation_player = $AnimationPlayer

func _process(delta: float) -> void:
	self.global_position = origin_position + offset