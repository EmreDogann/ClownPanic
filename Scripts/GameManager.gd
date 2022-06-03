extends Node

onready var smp = get_node("../StateMachinePlayer")

onready var blankWindow = preload("res://Scenes/BlankWindow.tscn")

onready var fileSystem = get_tree().root.get_node("Node2D/CanvasLayer/FileExplorer/Window/VBoxContainer/Body/MarginContainer/VBoxContainer/Files")
#onready var fileItemScript = load("res://FileTree/FileItem.cs")
#var fileItemNode

var current_level: int = 0

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
#	smp.set_param("jump_count", 1)
#	smp.get_param("on_floor", false)
#	smp.has_param("velocity")
	
	rng.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#pass

func next_level():
	print("Load next level...")

func virus_deleted():
	next_level()

func spawn_window() -> void:
	pass

func terminal_game_over() -> void:
	print("Game Over!")

func _on_StateMachinePlayer_updated(state, delta) -> void:
	match state:
#	print(state)
		"Level 1/Spawn Virus":
#			print(fileSystem.GetListOfFiles())
#			fileSystem.addVirusRandomly("VIRUS.v", false, "", FILE_TYPE.FILE)
			pass
