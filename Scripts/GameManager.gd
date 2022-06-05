extends Node2D

onready var smp = $StateMachinePlayer

onready var player: AnimationPlayer = get_node("../AnimationPlayer")
onready var blankWindow = preload("res://Scenes/BlankWindow.tscn")
onready var fileSystem = get_tree().root.get_node("Node2D/CanvasLayer/FileExplorer/Window/VBoxContainer/Body/MarginContainer/VBoxContainer/Files")
onready var itemList: ItemList = get_tree().root.get_node("Node2D/CanvasLayer/FileExplorer/Window/VBoxContainer/Body/MarginContainer/VBoxContainer/Files/HSplitContainer/VBoxContainer2/Control/ItemList")
onready var audioManager = get_tree().root.get_node("Node2D/AudioManager")
onready var wallpaperNode = get_tree().root.get_node("Node2D/CanvasLayer/Desktop/Panel/Wallpaper")
onready var terminalNode = get_tree().root.get_node("Node2D/CanvasLayer/Terminal")
onready var mouseNode = get_tree().root.get_node("Node2D/CanvasLayer/Mouse")

onready var virusGlitch = get_node("../CanvasLayer/FileExplorer/Window/VBoxContainer/Body/MarginContainer/VBoxContainer/Files/HSplitContainer/VBoxContainer2/Control/ItemList/Virus Glitch")
onready var crtFilter = get_node("../CanvasLayer/Post-Processing Effects/CRT Filter/Effect")

var staticIntensity: float = 0.1
var staticIntensityTargetWeight: float
var staticIntensityLerpWeight: float
var staticIntensityLerpTime: float = 2.0
var shouldChangeStaticIntensity = false

var wallpaperTransitionReady: bool = false
var wallpaperTimerCooldown = 10.0
var wallpaperTimer = wallpaperTimerCooldown
var totalWallpaperTransition = 0

var itemListPollCooldown: float = 0.2
var itemListPollTimer: float = itemListPollCooldown

var windowPopupCooldown: float = 0.5
var windowPopupTimer: float = windowPopupCooldown

var bleedFileTreeAmount = 0.0;

var currentLevel = 1
var distanceToVirus: int
var virusPosition: int

onready var player_health: int = 4;
onready var ui_elements_to_turn_off: Dictionary = {
	3: [get_node("../CanvasLayer/FileExplorer/Window/VBoxContainer/Titlebar/HBoxContainer/HBoxContainer"),
		get_node("../CanvasLayer/Terminal/Window/VBoxContainer/Titlebar/HBoxContainer/HBoxContainer")],
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
	smp.set_param("isMouseDisabled", false)
	
	player.connect("animation_finished", self, "animFinished")
	
	rng.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (wallpaperTransitionReady and totalWallpaperTransition <= 4):
		wallpaperTimer -= delta
	
	if (wallpaperTimer <= 0.0):
		wallpaperNode.change_wallpaper()
		wallpaperTimer = wallpaperTimerCooldown
		wallpaperTransitionReady = false
		totalWallpaperTransition += 1
	
	if (shouldChangeStaticIntensity):
		if (abs(staticIntensityLerpWeight - staticIntensityTargetWeight) <= 0.01):
			shouldChangeStaticIntensity = false
		else:
			staticIntensityLerpWeight += (delta  / staticIntensityLerpTime) * sign(staticIntensityTargetWeight - staticIntensityLerpWeight)
			staticIntensity = lerp(0.1, 0.4, clamp(staticIntensityLerpWeight, 0.0, 1.0))
			
			crtFilter.material.set('shader_param/static_noise_intensity', staticIntensity)
	
	if (virusGlitch.visible and virusPosition != -1):
		print(virusPosition)
		var position: Vector2
		position.y += (itemList.get_constant("line_separation") + itemList.get_constant("vseparation") + 16) * (virusPosition)
		position.y -= (itemList.get_v_scroll().value)
		var size: Vector2 = Vector2(itemList.rect_size.x, 17)
		
		virusGlitch.rect_position = position
		virusGlitch.rect_size = size
	else:
		itemListPollTimer -= delta
		
		if (itemListPollTimer <= 0.0):
			itemListPollTimer = itemListPollCooldown
			var hoveredIndex = itemList.get_item_at_position(itemList.get_local_mouse_position(), false)
			
			if (hoveredIndex != -1):
				var distance = fileSystem.getHoveredDistance(itemList.get_item_metadata(hoveredIndex))
				audioManager.increase_static_volume(distance)
				shouldChangeStaticIntensity = true
				staticIntensityTargetWeight = 1 - 0.2 * (distance + 1)
				
				distanceToVirus = distance

func animFinished(anim_name: String) -> void:
	match anim_name:
		"WrongTransition":
			smp.set_trigger("TransitionFinished")
		"CorrectTransition":
			smp.set_trigger("TransitionFinished")
		"GameOver":
			smp.set_trigger("PlayCredits")

func _on_StateMachinePlayer_updated(state, delta) -> void:
	match state:
		"Level1/Idle":
			if (smp.get_param("Level1/IdleTimer", 0.0) < 15.0):
				smp.set_param("Level1/IdleTimer", smp.get_param("Level1/IdleTimer", 0.0) + delta)
				if (smp.get_param("Level1/IdleTimer", 0.0) >= 15.0):
					smp.set_trigger("SpawnVirus")
		"Level4/Idle":
			windowPopupTimer -= delta
		
			if (windowPopupTimer <= 0.0):
				windowPopupTimer = windowPopupCooldown
				
				smp.set_param("spawnChance", rng.randi_range(0, 100))
		"Level5/Idle":
			if (!smp.get_param("isMouseDisabled")):
				smp.set_param("disableTimer", smp.get_param("disableTimer", 0.0) + delta)

func _on_StateMachinePlayer_transited(from, to) -> void:
	prints("Transition(%s -> %s)" % [from, to])
	match to:
		"Level1/Spawn Virus":
			fileSystem.addVirusRandomly("VIRUS.pdf", false, "", FILE_TYPE.FILE)
			
			wallpaperTransitionReady = true
			totalWallpaperTransition = 0
			
			audioManager.virus_deleted()
			audioManager.play_static()
			smp.set_trigger("SpawnVirusTransition")
		"Level1/Play Wrong Transition", "Level2/Play Wrong Transition", "Level3/Play Wrong Transition", "Level4/Play Wrong Transition", "Level5/Play Wrong Transition":
			player.play("WrongTransition")
		"Level1/Play Correct Transition", "Level2/Play Correct Transition", "Level3/Play Correct Transition", "Level4/Play Correct Transition", "Level5/Play Correct Transition":
			player.play("CorrectTransition")
		"Level2/Entry", "Level3/Entry", "Level4/Entry", "Level5/Entry":
			smp.set_param("isVirusDeleted", false)
			
			if (bleedFileTreeAmount == 0.0):
				bleedFileTreeAmount += 0.35 * currentLevel
				fileSystem.bleedFileTrees(bleedFileTreeAmount);
		"Level2/Idle":
			if (from == "Level2/Entry"):
				currentLevel = 2
				smp.set_trigger("SpawnVirus")
		"Level2/Spawn Virus":
			fileSystem.addVirusRandomly("VIRUS.exe", false, "", FILE_TYPE.EXECUTABLE)
			
			wallpaperTransitionReady = true
			totalWallpaperTransition = 0
			
			smp.set_trigger("VirusSpawned")
		"Level3/Idle":
			if (from == "Level3/Entry"):
				currentLevel = 3
				smp.set_trigger("ActivateTerminal")
			elif (from == "Level3/Activate Terminal"):
				smp.set_trigger("SpawnVirus")
		"Level3/Activate Terminal":
			terminalNode.activate_terminal();
			smp.set_trigger("TerminalActive")
		"Level3/Spawn Virus", "Level4/Spawn Virus", "Level5/Spawn Virus":
			fileSystem.addVirusRandomly("VIRUS.v", true, "", FILE_TYPE.FILE)
			
			wallpaperTransitionReady = true
			totalWallpaperTransition = 0
			
			smp.set_trigger("VirusSpawned")
		"Level4/Idle":
			if (from == "Level4/Entry"):
				currentLevel = 4
				smp.set_trigger("SpawnVirus")
		"Level4/Popup Window":
			var instance = blankWindow.instance()
			get_tree().root.get_node("Node2D/CanvasLayer/PopupWindows").add_child(instance)
			
			smp.set_param("spawnChance", -1)
			smp.set_trigger("WindowSpawned")
		"Level5/Idle":
			if (from == "Level5/Entry"):
				currentLevel = 5
				terminalNode.ambiguous_text()
				smp.set_trigger("SpawnVirus")
		"Level5/Disable Mouse":
			itemList.grab_focus()
			if (itemList.get_item_count() > 0):
				itemList.select(0)
			
			mouseNode.disable_mouse()
			smp.set_param("isMouseDisabled", true)
		"GameOver":	
			player.play("GameOver")
		"Play Credits":
			player.play("Credits")

func wallpaper_transition_finished():
	wallpaperTransitionReady = true

func virus_distance_update(incrementAmount: float):
	audioManager.increase_static_volume(incrementAmount)
	shouldChangeStaticIntensity = true
	staticIntensityTargetWeight = 1 - 0.2 * (incrementAmount + 1)
	
	distanceToVirus = incrementAmount
	
	if (distanceToVirus == 0):
		virusPosition = fileSystem.getVirusPosition()
		virusGlitch.visible = true
	else:
		virusGlitch.visible = false

func virus_deleted():
	virusGlitch.visible = false
	
	audioManager.virus_deleted()
	smp.set_param("isVirusDeleted", true)

func wrong_file_deleted():
	player_health -= 1
	smp.set_param("Health", player_health)
	
	audioManager.wrong_file_deleted()
	smp.set_trigger("WrongFileDeleted")
	
	if (player_health == 3):
		for ui_element in ui_elements_to_turn_off[player_health]:
			ui_element.get_parent().remove_child(ui_element)
	elif (player_health != 0):
		ui_elements_to_turn_off[player_health].get_parent().remove_child(ui_elements_to_turn_off[player_health])

func spawn_window() -> void:
	pass

func play_terminal_beep() -> void:
	audioManager.terminal_beep()

func terminal_game_over() -> void:
	smp.set_param("Health", 0)
	audioManager.increase_static_volume(0)

func end_game():
	get_tree().quit()

func bleedFiles() -> void:
	if (currentLevel != 1):
		bleedFileTreeAmount += 0.35
		fileSystem.bleedFileTrees(bleedFileTreeAmount);

func clear_terminals():
	if (currentLevel == 4):
		get_node("../CanvasLayer/PopupWindows").queue_free()
