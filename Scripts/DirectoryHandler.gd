extends Node

# var FileItem = load("res://FileItem.gd")


# var tree = Tree.new()
onready var tree = get_node("HSplitContainer/GDTree")
# onready var itemList = get_node("HSplitContainer/ItemList")
var treeItems = []
var root


# class FileItem:
# 	extends TreeItem
# 	enum FILE_TYPES { DIRECTORY, IMAGE, DOCUMENT }

# 	var filepath
# 	var filetype

# 	var filesize  # may be unused

# 	func set_filepath(path: String):
# 		filepath = path

# 	func set_filetype(type: int):
# 		if type <= FILE_TYPES.size():
# 			filetype = type
# 		else:
# 			print("INVALID FILE TYPE: SETTING TYPE TO DOCUMENT - Thrown by FileItem.gd")
# 			filetype = FILE_TYPES.DOCUMENT


# Called when the node enters the scene tree for the first time.
func _ready():


	root = tree.create_item()
	root.set_text(0, "root")
	var files = get_dir_contents("C:/Users/aum/Documents/Documents/IDEAS")

	pass  # Replace with function body.


# class Item:
# 	var path # Absolute Path
# 	var parent # absolute path to parent
# 	var coreParent # Desktop, Documents, Downloads, Pictures, Videos.
# 	var type # Directory, Image, Video, Document
# 	var fileSize


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	# if (Input.is_action_just_pressed("ui_up")):
	# 	#var files = get_dir_contents("C:/Users/aum/Documents/Coding")

	# print(tree)
	
	# for file in files:
	# print(file)

	# list_files_in_directory("C:/Users/aum/Documents/Coding/Abu")


func _on_Tree_item_selected():
	var selectedItem = tree.get_selected()
	var child = selectedItem.get_children()
	while child != null:
		print(child.get_text(0))
		child = child.get_next()


# Reading the Directories


# Reference: https://godotengine.org/qa/5175/how-to-get-all-the-files-inside-a-folder
func get_dir_contents(rootPath: String) -> Array:
	var files = []
	var directories = []
	var dir = Directory.new()

	if dir.open(rootPath) == OK:
		dir.list_dir_begin(true, false)
		_add_dir_contents(dir, files, directories, root)
	else:
		push_error("An error occurred when trying to access the path.")

	return [files, directories]


# Reference: https://godotengine.org/qa/5175/how-to-get-all-the-files-inside-a-folder
func _add_dir_contents(dir: Directory, files: Array, directories: Array, parent: TreeItem):
	var file_name = dir.get_next()

	while file_name != "":
		var path = dir.get_current_dir() + "/" + file_name
		if dir.current_is_dir():
			if file_name[0] != ".":
				# print("Found directory: %s" % path)
				var subDir = Directory.new()
				subDir.open(path)
				subDir.list_dir_begin(true, false)
				directories.append(path)

				var child = tree.create_item(parent)
				child.set_text(0, file_name)
				treeItems.append(child)

				_add_dir_contents(subDir, files, directories, child)
		else:
			if file_name[0] != ".":
				# print("Found file: %s" % path)

				var child = tree.create_item(parent)
				
				child.set_text(0, file_name)
				treeItems.append(child)
				files.append(path)

		file_name = dir.get_next()

	dir.list_dir_end()
