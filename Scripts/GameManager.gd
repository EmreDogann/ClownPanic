extends Node



#var directoryHandlerClass = load("res://FileTree/DirectoryHandler.cs")
onready var fileSystem = get_tree().root.get_node("Node2D/CanvasLayer/FileExplorer/Window/VBoxContainer/Body/MarginContainer/VBoxContainer/Files")
var fileItem
# Called when the node enters the scene tree for the first time.
func _ready():
	# call to add virus. if hidden is true, name of virus may be blank
<<<<<<< HEAD
#	fileItem = fileSystem.addVirusRandomly("Level1Virus", false)
	fileSystem.connect("virus_deleted", self, "next_level")
=======
	#fileItem = fileSystem.addVirusRandomly("Level1Virus", false)
	#fileSystem.connect("virus_deleted", self, "next_level")
>>>>>>> 761b9f6f200d26130ae8435b15ce1f294cbf8df0
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#pass

func next_level():
	print("Load next level...")

func virus_deleted():
	next_level()
