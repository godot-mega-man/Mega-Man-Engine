extends EnemyCore


const PLATFORM = preload("res://Src/Node/GameObj/Enemy/Obj/MM10_TricastlePlatform.tscn")

const PLATFORM_SPAWN_INITIAL_DELAY = 1.1
const PLATFORM_SPAWN_INTERVAL = 0.6
const PLATFORM_SPAWN_OFFSETS = [Vector2(0, 8), Vector2(0, -8)]
const PLATFORM_SPEEDS = [120, 180]


func spawn():
	$DelayTimer.start(PLATFORM_SPAWN_INITIAL_DELAY)
	yield($DelayTimer, "timeout")
	
	# Spawn platforms in a random particular order
	var order = range(2)
	order.shuffle()
	
	for i in order:
		_spawn_platform(i)
		$SpawnIntervalTimer.start(PLATFORM_SPAWN_INTERVAL)
		yield($SpawnIntervalTimer, "timeout")


func _spawn_platform(id : int):
	var platform = PLATFORM.instance()
	get_parent().add_child(platform)
	platform.global_position = global_position
	platform.position += PLATFORM_SPAWN_OFFSETS[id]
	platform.set_speed(PLATFORM_SPEEDS[id])
