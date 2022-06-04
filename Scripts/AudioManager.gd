extends Node

var backgroundNoises: Array
var mouseSFX: Array
var keyboardSFX: Array
var deletedSFX: Array

var players: Array
var currentPlayer: int = 6
var PLAYERS_COUNT: int = 20

var startupSound: bool = false

var time_delay: float

var rng = RandomNumberGenerator.new()

var staticVolume: float = -30.0
var staticVolumeBefore: float = 0.0
var staticVolumeIncrementSpeed: float = 1.0
var staticVolumeIncrementAmount: float
var shouldIncreaseStaticVolume: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# ---- Load audio files ----
	# Background Noise
	backgroundNoises.append(preload("res://SoundEffects/Background Noise/ComputerBackgroundNoise1.wav"))
	backgroundNoises.append(preload("res://SoundEffects/Background Noise/ComputerBackgroundNoise2.wav"))
	backgroundNoises.append(preload("res://SoundEffects/Background Noise/ComputerBackgroundNoise2 - FadeOut.wav"))
	backgroundNoises.append(preload("res://SoundEffects/Background Noise/Computer Turn Off.wav"))
	backgroundNoises.append(preload("res://SoundEffects/Static/Static.wav"))
	
	# Mouse SFX
	mouseSFX.append(preload("res://SoundEffects/Mouse Impact/Mouse Disable.wav"))
	mouseSFX.append(preload("res://SoundEffects/Mouse Impact/Mouse Impact.wav"))
	mouseSFX.append(preload("res://SoundEffects/Foley/Mouse/Mouse - Pressed.wav"))
	mouseSFX.append(preload("res://SoundEffects/Foley/Mouse/Mouse - Released.wav"))
	
	# Keyboard SFX
	keyboardSFX.append(preload("res://SoundEffects/Foley/Keyboard/Keyboard1.wav"))
	keyboardSFX.append(preload("res://SoundEffects/Foley/Keyboard/Keyboard2.wav"))
	keyboardSFX.append(preload("res://SoundEffects/Foley/Keyboard/Keyboard3.wav"))
	keyboardSFX.append(preload("res://SoundEffects/Foley/Keyboard/Keyboard4.wav"))
	keyboardSFX.append(preload("res://SoundEffects/Foley/Keyboard/Keyboard5.wav"))
	keyboardSFX.append(preload("res://SoundEffects/Foley/Keyboard/Keyboard6.wav"))
	keyboardSFX.append(preload("res://SoundEffects/Foley/Keyboard/Keyboard7.wav"))
	keyboardSFX.append(preload("res://SoundEffects/Foley/Keyboard/Keyboard8.wav"))
	keyboardSFX.append(preload("res://SoundEffects/Foley/Keyboard/Keyboard9.wav"))
	keyboardSFX.append(preload("res://SoundEffects/Foley/Keyboard/Keyboard10.wav"))
	keyboardSFX.append(preload("res://SoundEffects/Foley/Keyboard/Keyboard11.wav"))
	
	# Deleted SFX
	deletedSFX.append(preload("res://SoundEffects/Delete SFX/Delete Fail - Combined.wav"))
	deletedSFX.append(preload("res://SoundEffects/Delete SFX/Virus Deleted - Final.wav"))
	# --------------------------
	
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
	
	rng.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ($BackgroundNoiseStartUp.get_playback_position() + time_delay >= $BackgroundNoiseStartUp.stream.get_length() and !startupSound):
		play_specific(backgroundNoises[1], 0)
		play_specific(backgroundNoises[0], 1)
		startupSound = true
	
	if (shouldIncreaseStaticVolume):
		print(staticVolume)
		staticVolume += (delta / (staticVolumeBefore + staticVolumeIncrementAmount)) * staticVolumeIncrementSpeed
		
		players[5].volume_db = staticVolume
		
		if (staticVolume >= staticVolumeBefore + staticVolumeIncrementAmount):
			shouldIncreaseStaticVolume = false

func play_specific(sample: AudioStreamSample, player_num: int) -> void:
	players[player_num].stream = sample
	players[player_num].play()

func play(sample: AudioStream) -> void:
	players[currentPlayer].stream = sample
	players[currentPlayer].play()
	
	currentPlayer += 1
	
	# players 0 and 1 are reserved for the background noise.
	# 2 and 3 are reserved for mouse clicks.
	# 4 is for mouse collisions.
	# 5 is for virus static noise.
	if (currentPlayer % PLAYERS_COUNT == 0):
		currentPlayer = 6

func play_random_pitch(sample: AudioStreamSample, pitch_intensity: int) -> void:
	var randomPitchShift: AudioStreamRandomPitch = AudioStreamRandomPitch.new()
	randomPitchShift.audio_stream = sample
	randomPitchShift.random_pitch = pitch_intensity
	play(randomPitchShift)

func shutdown_pc() -> void:
	play_specific(backgroundNoises[2], 0)
	players[1].volume_db = 10.0
	play_specific(backgroundNoises[3], 1)

func mouse_disabled() -> void:
	play(mouseSFX[0])

func mouse_collided() -> void:
	if (!players[4].playing):
		play_specific(mouseSFX[1], 4)

func mouse_pressed() -> void:
	play_specific(mouseSFX[2], 2)

func mouse_released() -> void:
	play_specific(mouseSFX[3], 3)

func key_pressed() -> void:
	play_random_pitch(keyboardSFX[rng.randi_range(0, 10)], 1.1)

func virus_deleted() -> void:
	play(deletedSFX[1])

func wrong_file_deleted() -> void:
	play(deletedSFX[0])

func play_static() -> void:
	players[5].volume_db = staticVolume
	play_specific(backgroundNoises[4], 5)

func increase_static_volume(incrementAmount: float) -> void:
	staticVolumeBefore = staticVolume
	staticVolumeIncrementAmount = incrementAmount
	shouldIncreaseStaticVolume = true

#func on_player_finished(player: AudioStreamPlayer) -> void:
#	remove_child(player)
#	print("Removed Player!")
