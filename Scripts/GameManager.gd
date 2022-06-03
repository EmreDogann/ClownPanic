extends Node
#var directoryHandlerClass = load("res://FileTree/DirectoryHandler.cs")
onready var fileSystem = get_tree().root.get_node("Node2D/CanvasLayer/FileExplorer/Window/VBoxContainer/Body/MarginContainer/VBoxContainer/Files")
var fileItem
# Called when the node enters the scene tree for the first time.
func _ready():
	# call to add virus. if hidden is true, name of virus may be blank
#	fileItem = fileSystem.addVirusRandomly("Level1Virus", false)
	fileSystem.connect("virus_deleted", self, "next_level")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#pass


func next_level():
	print("Load next level...")
