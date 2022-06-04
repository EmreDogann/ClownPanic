extends Node

#onready var smp = get_node("../StateMachinePlayer")
onready var smp = $StateMachinePlayer
const YAFSM = preload("res://addons/imjp94.yafsm/YAFSM.gd")
const StackPlayer = YAFSM.StackPlayer
const StateMachinePlayer = YAFSM.StateMachinePlayer
const StateMachine = YAFSM.StateMachine
const State = YAFSM.State

onready var blankWindow = preload("res://Scenes/BlankWindow.tscn")

onready var fileSystem = get_tree().root.get_node("Node2D/CanvasLayer/FileExplorer/Window/VBoxContainer/Body/MarginContainer/VBoxContainer/Files")
onready var audioManager = get_tree().root.get_node("Node2D/AudioManager")

onready var wrongFileGlitch = get_node("../CanvasLayer/Post-Processing Effects/Wrong File Glitch/Effect")
onready var distortion = get_node("../CanvasLayer/Post-Processing Effects/Distortion/Effect")
onready var virusGlitch = get_node("../CanvasLayer/Post-Processing Effects/Virus Glitch/Effect");
onready var crtClose = get_node("../CanvasLayer/Post-Processing Effects/CRT Close/Effect");
onready var crtFilter = get_node("../CanvasLayer/Post-Processing Effects/CRT Filter/Effect");

onready var transitionTimer = 0.0
onready var transitionFadeOutAmplitude = 1.0
onready var transitionFadeOutAmplitudeMultipler = 1.0

onready var wrongTransitionFadeOutCooldown = 0.2
onready var wrongTransitionFadeOutTimer = wrongTransitionFadeOutCooldown
onready var correctTransitionFadeOutCooldown = 1.0
onready var correctTransitionFadeOutTimer = correctTransitionFadeOutCooldown

onready var gameOverCooldown = 1.0
onready var gameOverTimer = gameOverCooldown

onready var crtCloseFadeOutCooldown = 1.0
onready var crtCloseFadeOutTimer = crtCloseFadeOutCooldown

var staticIntensity: float = 0.1
var staticIntensityTargetWeight: float
var staticIntensityLerpWeight: float
var staticIntensityLerpTime: float = 3.0
var shouldChangeStaticIntensity = false

# get_node("../CanvasLayer/FileExplorer/Window/VBoxContainer/Titlebar/HBoxContainer/HBoxContainer")
onready var player_health: int = 4;
onready var ui_elements_to_turn_off: Dictionary = {
	3: [get_node("../CanvasLayer/FileExplorer/Window/VBoxContainer/Titlebar/HBoxContainer/HBoxContainer")],
	2: get_node("../CanvasLayer/Desktop/Panel/TaskBar"),
	1: get_node("../CanvasLayer/FileExplorer/Window/VBoxContainer/Body/MarginContainer/VBoxContainer/Controls/HBoxContainer/ControlButtons"),
}

var rng = RandomNumberGenerator.new()

enum FILE_TYPE {
		DIRECTORY, # 0
		IMAGE, # 1
		VIDEO, # 2
		AUDIO, # 3
		EXECUTABLE, # 4
		FILE, # 5
		NULL # 6
	}

# Called when the node enters the scene tree for the first time.
func _ready():
#	fileItemNode = fileItemScript.new("")
	
	# Call to add virus. if hidden is true, name of virus may be blank.
#	fileSystem.connect("virus_deleted", self, "next_level")
#	smp.set_trigger("jump")
#	smp.set_param("timer", 0.0)
#	smp.get_param("on_floor", false)
#	smp.has_param("velocity")
	
	smp.set_param("Health", player_health)
	smp.set_param("Level1/IdleTimer", 0.0)
	smp.set_param("isVirusDeleted", false)
	
	rng.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (shouldChangeStaticIntensity):
		if (abs(staticIntensityLerpWeight - staticIntensityTargetWeight) <= 0.01):
			shouldChangeStaticIntensity = false
		else:
#			print(staticVolume)
			staticIntensityLerpWeight += (delta  / staticIntensityLerpTime) * sign(staticIntensityTargetWeight - staticIntensityLerpWeight)
			staticIntensity = lerp(0.1, 0.8, staticIntensityLerpWeight)
			
			crtFilter.material.set('shader_param/static_noise_intensity', staticIntensity)
			

func virus_distance_update(incrementAmount: float):
	print(incrementAmount)
	audioManager.increase_static_volume(incrementAmount)
#	shouldChangeStaticIntensity = true
#	staticIntensityTargetWeight = 1 - 0.1 * (incrementAmount + 1)

func virus_deleted():
	audioManager.virus_deleted()
	smp.set_param("isVirusDeleted", true)

func wrong_file_deleted():
	player_health -= 1
	smp.set_param("Health", player_health)
	
	transitionFadeOutAmplitudeMultipler += 0.35
	
	audioManager.wrong_file_deleted()
	smp.set_trigger("WrongFileDeleted")
	
	if (player_health == 3):
		for ui_element in ui_elements_to_turn_off[player_health]:
			ui_element.get_parent().remove_child(ui_element)
	elif (player_health != 0):
		ui_elements_to_turn_off[player_health].get_parent().remove_child(ui_elements_to_turn_off[player_health])

func spawn_window() -> void:
	pass

func terminal_game_over() -> void:
#	smp.set_param("Health", 0)
	pass

func _on_StateMachinePlayer_updated(state, delta) -> void:
	match state:
		"Level1/Idle":
			if (smp.get_param("Level1/IdleTimer", 0.0) < 1.0):
				smp.set_param("Level1/IdleTimer", smp.get_param("Level1/IdleTimer", 0.0) + delta)
				if (smp.get_param("Level1/IdleTimer", 0.0) >= 1.0):
					smp.set_trigger("SpawnVirus")
		"Level1/Play Wrong Transition":
			transitionTimer += delta
			
			wrongFileGlitch.material.set('shader_param/time', transitionTimer)
			distortion.material.set('shader_param/time', transitionTimer)
			
			if (transitionTimer >= 0.35): # Audio Length = 0.57s
				smp.set_trigger("FadeOutTransition")
		"Level1/Fade Out Error Transition":
			wrongTransitionFadeOutTimer -= delta
			
			transitionTimer += delta
			transitionFadeOutAmplitude -= transitionFadeOutAmplitudeMultipler * delta / wrongTransitionFadeOutCooldown
			
			wrongFileGlitch.material.set('shader_param/time', transitionTimer)
			distortion.material.set('shader_param/time', transitionTimer)
			wrongFileGlitch.material.set('shader_param/amplitude', transitionFadeOutAmplitude)
			distortion.material.set('shader_param/amplitude', transitionFadeOutAmplitude)
			
			if (wrongTransitionFadeOutTimer <= 0.0):
				smp.set_trigger("TransitionFinished")
				
				wrongTransitionFadeOutTimer = wrongTransitionFadeOutCooldown
				transitionTimer = 0.0
				
				transitionFadeOutAmplitude = 1.0 * transitionFadeOutAmplitudeMultipler
				wrongFileGlitch.material.set('shader_param/amplitude', transitionFadeOutAmplitude)
				distortion.material.set('shader_param/amplitude', transitionFadeOutAmplitude)
				
				wrongFileGlitch.get_parent().visible = false
				distortion.get_parent().visible = false
		"Level1/Play Correct Transition":
			delta *= 0.75
			transitionTimer += delta
			
			wrongFileGlitch.material.set('shader_param/time', transitionTimer)
			distortion.material.set('shader_param/time', transitionTimer)
			
			if (transitionTimer >= 0.35): # Audio Length = 0.57s
				smp.set_trigger("FadeOutTransition")
		"Level1/Fade Out Correct Transition":
			correctTransitionFadeOutTimer -= delta
			
			transitionTimer += delta
			transitionFadeOutAmplitude -= 1.5 * delta / correctTransitionFadeOutCooldown
			
			wrongFileGlitch.material.set('shader_param/time', transitionTimer)
			distortion.material.set('shader_param/time', transitionTimer)
			wrongFileGlitch.material.set('shader_param/amplitude', transitionFadeOutAmplitude)
			distortion.material.set('shader_param/amplitude', transitionFadeOutAmplitude)
			
			if (correctTransitionFadeOutTimer <= 0.0):
				smp.set_trigger("TransitionFinished")
				
				correctTransitionFadeOutTimer = correctTransitionFadeOutCooldown
				transitionTimer = 0.0
				
				transitionFadeOutAmplitude = 1.5
				wrongFileGlitch.material.set('shader_param/amplitude', transitionFadeOutAmplitude)
				distortion.material.set('shader_param/amplitude', transitionFadeOutAmplitude)
				
				distortion.material.set('shader_param/enableColorShifting', false)
				wrongFileGlitch.get_parent().visible = false
				distortion.get_parent().visible = false
		"GameOver":
			delta *= 0.25
			gameOverTimer -= delta
			
			wrongTransitionFadeOutTimer -= delta
			
			transitionTimer += delta
			transitionFadeOutAmplitude += 7.0 * delta / gameOverCooldown
			
			wrongFileGlitch.material.set('shader_param/time', transitionTimer)
			distortion.material.set('shader_param/time', transitionTimer)
			wrongFileGlitch.material.set('shader_param/amplitude', transitionFadeOutAmplitude)
			distortion.material.set('shader_param/amplitude', transitionFadeOutAmplitude)
			print (gameOverTimer)
			if (gameOverTimer <= 0.0):
				smp.set_trigger("GameOverTransition")
		"GameOverTransition":
			crtCloseFadeOutTimer -= delta
			
			delta *= 0.25
			transitionTimer += delta
			transitionFadeOutAmplitude += 5.0 * delta / gameOverCooldown
			
			crtClose.material.set('shader_param/time', 1.0 - crtCloseFadeOutTimer)
			
			wrongFileGlitch.material.set('shader_param/time', transitionTimer)
			distortion.material.set('shader_param/time', transitionTimer)
			wrongFileGlitch.material.set('shader_param/amplitude', transitionFadeOutAmplitude)
			distortion.material.set('shader_param/amplitude', transitionFadeOutAmplitude)
			
			if (crtCloseFadeOutTimer <= 0.0):
				smp.set_trigger("TransitionFinished")

func _on_StateMachinePlayer_transited(from, to) -> void:
	prints("Transition(%s -> %s)" % [from, to])
	match to:
		"Level1/Spawn Virus":
			print("Virus Spawned!")
			fileSystem.addVirusRandomly("VIRUS.v", false, "Desktop/Games", FILE_TYPE.FILE)
			audioManager.virus_deleted()
			audioManager.play_static()
			audioManager.increase_static_volume(fileSystem.getDistanceToVirus())
			smp.set_trigger("SpawnVirusTransition")
		"Level1/Play Wrong Transition":
			transitionFadeOutAmplitude = 1.0 * transitionFadeOutAmplitudeMultipler
			distortion.material.set('shader_param/enableColorShifting', false)
			distortion.material.set('shader_param/distortionDirection', 1)
			wrongFileGlitch.get_parent().visible = true;
			distortion.get_parent().visible = true;
		"Level1/Play Correct Transition":
			transitionFadeOutAmplitude = 1.5
			wrongFileGlitch.material.set('shader_param/amplitude', transitionFadeOutAmplitude)
			distortion.material.set('shader_param/amplitude', transitionFadeOutAmplitude)
			distortion.material.set('shader_param/enableColorShifting', true)
			distortion.material.set('shader_param/distortionDirection', 0)
			
			wrongFileGlitch.get_parent().visible = true;
			distortion.get_parent().visible = true;
		"GameOver":
			transitionTimer = -1.5
			transitionFadeOutAmplitude = 1.0
			wrongFileGlitch.material.set('shader_param/amplitude', transitionFadeOutAmplitude)
			distortion.material.set('shader_param/amplitude', transitionFadeOutAmplitude)
			distortion.material.set('shader_param/distortionDirection', 1)
			
			wrongFileGlitch.get_parent().visible = true;
			distortion.get_parent().visible = true;
		"GameOverTransition":
			audioManager.shutdown_pc()
			
			yield(get_tree().create_timer(5.0), "timeout")
			get_tree().quit()

func _on_StateMachinePlayer_entered(to) -> void:
#	match to:
#		"Level1/SpawnVirus":
#			print("Virus Spawned!")
#			fileSystem.addVirusRandomly("VIRUS.v", false, "", FILE_TYPE.FILE)
	pass


func _on_StateMachinePlayer_exited(from) -> void:
#	match from:
#		"Level1/SpawnVirus":
#			smp.set_param("isVirusSpawned", true)
	pass
