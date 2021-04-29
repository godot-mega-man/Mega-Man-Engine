extends EnemyCore

onready var bomb = $SpriteMain/MM9_c_HooHooBomb
onready var bullet_bhv = $BulletBehavior

var detected : bool = false
var fleeing : bool

func _ready() -> void:
	turn_toward_player()
	
	if sprite_main.scale.x != 1:
		bullet_bhv.angle_in_degrees -= 180

func _physics_process(delta: float) -> void:
	if not detected and abs(get_player_distance()) < 32:
		detach_bomb()
		flee()
		
		detected = true

func _on_MM9_c_HooHooBomb_dying() -> void:
	detach_bomb()
	flee()

func _on_MM9_HooHoo_dying() -> void:
	detach_bomb()

func detach_bomb():
	if detected:
		return
	if bomb == null:
		return
	if not is_instance_valid(bomb):
		return
	
	bomb.DESTROY_OUTSIDE_SCREEN = false
	sprite_main.move_child(bomb, 0)
	sprite_main.remove_child(bomb)
	get_parent().add_child(bomb)
	bomb.set_owner(get_parent())
	bomb.position += global_position
	bomb.DESTROY_OUTSIDE_SCREEN = true
	
	bomb.pf_bhv.INITIAL_STATE = true
	bomb.explode_countdown()

func flee():
	if fleeing:
		return
	
	sprite_main.scale.x = -sprite_main.scale.x
	bullet_bhv.acceleration -= 500
	fleeing = true
