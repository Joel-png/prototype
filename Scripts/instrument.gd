extends Holdable
class_name Instrument

@onready var audio_streamers_node = $AudioStreamers
@export var audio_library: AudioLibrary
@export var audio_dropoff_curve: Curve
var inputs: Array[String] = ["Y", "U", "I", "O", "P", "H", "J", "K", "L", ";", "N", "M", ",", ".", "slash"]
var sounds: Array[String] = ["c6", "d6", "e6", "f6", "g6", "a6", "b6", "c7", "d7", "e7", "f7", "g7", "a7", "b7", "c8"]
var input_bool: Array[bool]
var audio_streamers: Array[AudioStreamPlayer2D]
var audio_dropoff: Array[float]

func _ready():
	for i in range(0, inputs.size()):
		var audio_stream_player = AudioStreamPlayer2D.new()
		audio_stream_player.stream = AudioStreamPolyphonic.new()
		audio_stream_player.stream.polyphony = 1
		audio_stream_player.bus = "Instruments"
		audio_streamers.append(audio_stream_player)
		audio_streamers_node.add_child(audio_stream_player)
		
		audio_dropoff.append(0.0)
		input_bool.append(false)

@rpc("any_peer", "call_local")
func play_note(i):
	if not input_bool[i]:
		audio_streamers[i].stop()
		input_bool[i] = true
		audio_streamers[i].volume_db = 0
		play_sound_effect_from_library(sounds[i], i)
		audio_dropoff[i] = 0.0

@rpc("any_peer", "call_local")
func unpress_note(i):
	input_bool[i] = false

func play_sound_effect_from_library(_tag: String, i: int) -> void:
	if _tag:
		var audio_stream = audio_library.get_audio_stream(_tag)
		
		if !audio_streamers[i].playing:
			audio_streamers[i].play()
			
		var polyphonic_stream_playback = audio_streamers[i].get_stream_playback()
		polyphonic_stream_playback.play_stream(audio_stream)

func do_all_keys(_delta: float) -> void:
	for i in range(0, inputs.size()):
		if Input.is_action_pressed(inputs[i]):
			play_note.rpc(i)
		elif input_bool[i]:
			unpress_note.rpc(i)

func _process(delta: float) -> void:
	for i in range(0, inputs.size()):
		if not input_bool[i]:
			var current_volume = audio_streamers[i].volume_db
			if current_volume > -24.0:
				audio_dropoff[i] += delta
				audio_streamers[i].volume_db -= audio_dropoff_curve.sample(audio_dropoff[i])
			else:
				audio_streamers[i].stop()

func action(delta: float) -> void:
	do_all_keys(delta)
