extends Control

onready var mouseRef = get_tree().root.get_node("Node2D/CanvasLayer/Mouse")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pause_mode = Node.PAUSE_MODE_PROCESS
	self.hide()

func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("ui_pause") == true):
		if (!get_tree().paused):
			get_tree().paused = true
			get_parent().move_child(mouseRef, get_index())
			self.show()
		else:
			get_tree().paused = false
			get_parent().move_child(mouseRef, mouseRef.original_tree_position)
			self.hide()
