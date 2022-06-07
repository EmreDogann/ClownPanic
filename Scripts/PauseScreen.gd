extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pause_mode = Node.PAUSE_MODE_PROCESS
	self.hide()

func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("ui_pause") == true):
		if (!get_tree().paused):
			get_tree().paused = true
			self.show()
		else:
			get_tree().paused = false
			self.hide()
