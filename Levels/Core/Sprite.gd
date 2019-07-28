extends Sprite

onready var player = get_node("/root/Level/Iterable/Player")

func _process(delta: float) -> void:
	frame = player.current_hp