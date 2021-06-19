# Sfxes (sub-node of AudioCenter)

class_name Sfxes extends Node


class SfxOrder extends Reference:
	var stop : bool


signal about_to_play(audio_name)
signal playing(audio_name)


var sfx_audio_nodes : Dictionary


func play(sfx_name : String) -> AudioStreamPlayer:
	assert(
		sfx_audio_nodes.has(sfx_name),
		"Sfx " + sfx_name + " is not yet mapped or it could not be found."
		)
	
	var sfx = get_sfx(sfx_name)
	var sfx_order = SfxOrder.new()
	emit_signal("about_to_play", sfx_name, sfx_order)
	
	if sfx_order.stop:
		return sfx
	
	sfx.play()
	emit_signal("playing", sfx_name)
	return sfx


func stop(sfx_name : String) -> AudioStreamPlayer:
	assert(
		sfx_audio_nodes.has(sfx_name),
		"Sfx " + sfx_name + " is not yet mapped or it could not be found."
		)
	
	var sfx = get_sfx(sfx_name)
	sfx.stop()
	return sfx


func stop_all():
	for sfx in sfx_audio_nodes.values():
		sfx.stop()


# Map a new audio to the list of sfxes to make the method play() functional.
# Returns a newly created instance of AudioStreamPlayer where it is added. If
# the sfx was already mapped, an existing instance of AudioStreamPlayer is
# returned instead without adding the new sfx to the instance.
func add_sfx(new_sfx_name : String, sfx_wav : AudioStreamOGGVorbis):
	if sfx_audio_nodes.has(new_sfx_name):
		return get_sfx(new_sfx_name)
	
	var audio_stream_player := AudioStreamPlayer.new()
	self.add_child(audio_stream_player)
	audio_stream_player.stream = sfx_wav
	audio_stream_player.bus = "Sfx"
	
	# Map new sfx to list
	sfx_audio_nodes[new_sfx_name] = audio_stream_player


# Makes missing/unused mapped audios match with the currently available
# AudioStreamPlayer.
func remap_sfxes():
	sfx_audio_nodes.clear()
	
	for sfx in get_children():
		if not sfx is AudioStreamPlayer:
			continue
		
		sfx_audio_nodes[sfx.name] = sfx


func get_sfx(sfx_name) -> AudioStreamPlayer:
	return sfx_audio_nodes[sfx_name]


func is_sfx_playing(sfx_name : String) -> bool:
	if not sfx_audio_nodes.has(sfx_name):
		return false
	
	return get_sfx(sfx_name).is_playing()
