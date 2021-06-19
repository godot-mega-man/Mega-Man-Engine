extends EnemyCore

const NOTICE_DISTANCE = 48

export (float) var chain_tile_fall_spd = 100

var alerted : bool
const THIUNS = preload("res://Src/Node/GameObj/Effects/MM_Thiun/Thiun.tscn")


func _process(delta: float) -> void:
	_alert()

func _alert():
	if alerted:
		return
	
	if can_alert():
		alerted = true
		activate_switch_and_flee()

func activate_switch_and_flee():
	sprite_main.scale.x = 1
	$SpriteMain/Sprite/Anim.play("Activate")
	yield($SpriteMain/Sprite/Anim, "animation_finished")
	$SpriteMain/Sprite/Anim.play("JumpOff")
	yield($SpriteMain/Sprite/Anim, "animation_finished")
	queue_free()

# Make all switches activated
func make_switches_activated():
	get_tree().call_group("MM4Switch", "activate")
	Audio.play_sfx("crash_bomb")
	
	fasten_chain_tilemap()

func fasten_chain_tilemap():
	for ct in get_tree().get_nodes_in_group("ChainTilemap"):
		if Difficulty.difficulty == Difficulty.DIFF_NEWCOMER:
			ct.fall_speed = chain_tile_fall_spd * 0.3
		if Difficulty.difficulty == Difficulty.DIFF_CASUAL:
			ct.fall_speed = chain_tile_fall_spd * 0.6
		if Difficulty.difficulty == Difficulty.DIFF_NORMAL:
			ct.fall_speed = chain_tile_fall_spd
		if Difficulty.difficulty == Difficulty.DIFF_SUPERHERO:
			ct.fall_speed = chain_tile_fall_spd * 1.2

func face_opposite_dir():
	sprite_main.scale.x = -sprite_main.scale.x


func create_thuin() -> void:
	var speed = [60,120]
	var degrees_increment = 45
	var create_count = 8
	
	for i in speed:
		for j in create_count:
			var eff = THIUNS.instance()
			get_parent().add_child(eff)
			eff.get_node("BulletBehavior").angle_in_degrees = degrees_increment * j
			eff.get_node("BulletBehavior").speed = i
			eff.global_position = self.global_position
	
	Audio.play_sfx("player_dead")


func can_alert():
	return (
		get_player_distance() < NOTICE_DISTANCE or
		current_hp <= 2	
	)


func _on_WanderTimer_timeout() -> void:
	if alerted:
		$WanderTimer.stop()
		return
	
	face_opposite_dir()


func _on_MM6_KnightManChainEdit_slain(target) -> void:
	create_thuin()
