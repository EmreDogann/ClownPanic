extends Node

var mouseSFX: Array

var startupSound: bool = false
var shutdown: bool = false

var staticVolume: float
var staticVolumeCooldown: float = 0.5
var staticVolumeTime: float = staticVolumeCooldown
var staticVolumeWeight: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# ---- Load audio files ----
	# Mouse SFX
	mouseSFX.append(preload("res://SoundEffects/Mouse Impact/Mouse Disable.wav"))
	mouseSFX.append(preload("res://SoundEffects/Mouse Impact/Mouse Impact.wav"))
	mouseSFX.append(preload("res://SoundEffects/Foley/Mouse/Mouse - Pressed.wav"))
	mouseSFX.append(preload("res://SoundEffects/Foley/Mouse/Mouse - Released.wav"))
	# --------------------------

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (startupSound):
		staticVolumeTime -= delta
		staticVolumeWeight += (delta  / staticVolumeCooldown)
		staticVolume = lerp(-30.0, -5.0, staticVolumeWeight)
		
		$Static.volume_db = staticVolume
		
		if (staticVolumeTime <= 0.0):
			staticVolumeTime = staticVolumeCooldown
			startupSound = false
	if (shutdown):
		staticVolumeTime -= delta
		staticVolumeWeight -= (delta  / staticVolumeCooldown)
		staticVolume = lerp(-30.0, -5.0, staticVolumeWeight)
		
		$Static.volume_db = staticVolume
		
		if (staticVolumeTime <= 0.0):
			staticVolumeTime = staticVolumeCooldown
			shutdown = false

func mouse_pressed() -> void:
	$MousePress.play()

func mouse_released() -> void:
	$MouseRelease.play()

func next_scene() -> void:
	shutdown = true

func crt_done() -> void:
	startupSound = true
	$Static.volume_db = -30.0
	$Static.play()
