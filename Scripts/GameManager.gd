extends Node

onready var fileSystem = get_tree().root.get_node("Node2D/CanvasLayer/FileExplorer/Window/VBoxContainer/Body/MarginContainer/VBoxContainer/Files")
onready var blankWindow = preload("res://Scenes/BlankWindow.tscn")

var current_level: int = 0

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Call to add virus. if hidden is true, name of virus may be blank.
#	fileSystem.connect("virus_deleted", self, "next_level")
	
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
