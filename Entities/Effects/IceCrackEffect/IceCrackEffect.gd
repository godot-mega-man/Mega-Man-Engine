extends Sprite

onready var bullet_bhv := $BulletBehavior

func _ready():
	self.frame = randi() % hframes

func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()
