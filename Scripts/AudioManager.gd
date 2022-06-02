extends Node2D

var backgroundNoises: Array

var players: Array
var currentPlayer: int = 0
var PLAYERS_COUNT: int = 20

var startupSound: bool = false

var time_delay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	backgroundNoises.append(preload("res://SoundEffects/Background Noise/ComputerBackgroundNoise1.wav"))
	backgroundNoises.append(preload("res://SoundEffects/Background Noise/ComputerBackgroundNoise2.wav"))
	backgroundNoises.append(preload("res://SoundEffects/Background Noise/ComputerBackgroundNoise2 - FadeOut.wav"))
	
	# Set background noises 0 and 1 to loop
	backgroundNoises[0].loop_mode = AudioStreamSample.LOOP_FORWARD
	backgroundNoises[1].loop_mode = AudioStreamSample.LOOP_FORWARD
	
	for i in range(PLAYERS_COUNT):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		players.append(player)
		add_child(player)
#		player.connect("finished", self, "on_player_finished", [player])
	
	# Get estimated time delay for the audio to actually start playing on the player's audio device.
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	
	# Players 0 and 1 are reserved for background noises.
	players[0].bus = "Background"
	players[1].bus = "Background"
	$BackgroundNoiseStartUp.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ($BackgroundNoiseStartUp.get_playback_position() + time_delay >= $BackgroundNoiseStartUp.stream.get_length() and !startupSound):
		play_specific(backgroundNoises[1], 0)
		play_specific(backgroundNoises[0], 1)
		startupSound = true

func play_specific(sample: AudioStreamSample, player_num: int) -> void:
	players[player_num].stream = sample
	players[player_num].play()

func play(sample: AudioStreamSample) -> void:
	players[currentPlayer].stream = sample
	players[currentPlayer].play()
	
	currentPlayer += 1
	if (currentPlayer % PLAYERS_COUNT == 0):
		currentPlayer = 2 # players 0 and 1 are reserved for the background noise

#func on_player_finished(player: AudioStreamPlayer) -> void:
#	remove_child(player)
#	print("Removed Player!")
