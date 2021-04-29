extends Node


var time : float # in seconds
var paused : bool = true


func _process(delta: float) -> void:
	if not paused:
		time += delta


func start():
	paused = false


func stop():
	paused = true


func reset():
	time = 0


func get_playtime_string() -> String:
	var minute = int(time / 60)
	var second = int(time) % 60
	var msecond = stepify(fmod(time, 1) * 100, 1)
	
	var text_minute = str(minute)
	var text_second = str(second)
	var text_msecond = str(msecond)
	
	if second < 10:
		text_second = str("0", second)
	if msecond < 10:
		text_msecond = str("0", msecond)
	
	return str(text_minute, ":", text_second, ".", text_msecond)
