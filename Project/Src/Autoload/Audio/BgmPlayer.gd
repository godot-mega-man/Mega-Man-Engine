class_name BgmPlayer extends Node


enum RepeatMode {
	NONE,
	ALL,
	TRACK
}


# Audio Playback
onready var audio_stream_player : AudioStreamPlayer = $AudioStreamPlayer

# Effects for playback
onready var bgm_effect_anim : BgmEffectAnim = $AudioStreamPlayer/BgmEffectAnim


var repeat_mode : int = RepeatMode.NONE

var playlist_queue : Array

# The index of the now playing item in the current playback queue.
var current_track_idx : int

var playing : bool


func play(bgm : AudioStreamOGGVorbis):
	playing = true
	audio_stream_player.stream = bgm
	audio_stream_player.volume_db = 0
	audio_stream_player.play()


func play_from_queue():
	if playlist_queue.empty():
		push_error("Can't play bgm while the queue is empty.")
		return
	
	play(playlist_queue[current_track_idx])


# Pauses the audio playback if the parameter is true, or resumes if false.
func pause(paused : bool):
	playing = !paused
	audio_stream_player.stream_paused = paused


func stop():
	playing = false
	audio_stream_player.stream_paused = false
	audio_stream_player.stop()


# Closes the audio player and clear all items in the playback queue.
func close():
	audio_stream_player.stream_paused = false
	audio_stream_player.stream = null
	stop()
	clear_playlist()


# Starts playback of the next bgm item in the playback queue; or,
# the audio player is not playing, designates the next bgm as the next
# to be played.
func next():
	if repeat_mode == RepeatMode.NONE and not has_next():
		return
	
	current_track_idx = wrapi(current_track_idx + 1, 0, playlist_queue.size())
	play_from_queue()


# Returns true if the next bgm item in the playback queue is available.
func has_next() -> bool:
	return current_track_idx < playlist_queue.size() - 1


# Returns the next bgm item in the playback queue if available.
func get_next() -> AudioStreamOGGVorbis:
	return playlist_queue[current_track_idx + 1]


# Starts playback of the previous bgm item in the playback queue; or,
# the audio player is not playing, designates the previous bgm item as the next
# to be played.
func prev():
	if repeat_mode == RepeatMode.NONE and not has_prev():
		return
	
	current_track_idx = wrapi(current_track_idx - 1, 0, playlist_queue.size())
	play_from_queue()


# Returns true if the previous bgm item in the playback queue is available.
func has_prev() -> bool:
	return current_track_idx != 0


# Returns the previous bgm item in the playback queue if available.
func get_prev() -> AudioStreamOGGVorbis:
	return playlist_queue[current_track_idx - 1]


func get_current_track() -> AudioStream:
	return audio_stream_player.stream


# Insert the bgm item after the last bgm in the current queue.
func enqueue(bgm : AudioStreamOGGVorbis):
	playlist_queue.append(bgm)


# Insert bgm items after the last bgm in the current queue.
func enqueue_all(bgms : Array):
	playlist_queue += bgms


func clear_playlist():
	playlist_queue.clear()
	current_track_idx = 0


func _on_AudioStreamPlayer_finished() -> void:
	if not playing:
		return
	
	match repeat_mode:
		RepeatMode.NONE:
			next()
		RepeatMode.ALL:
			next()
		RepeatMode.TRACK:
			play_from_queue()
