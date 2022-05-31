extends TextureRect

signal window_moved()

var drag_position =  null
var root_window

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root_window = get_parent().get_parent().get_parent()
	pass # Replace with function body.


func _on_Titlebar_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton):
		if event.pressed:
			drag_position = self.get_global_mouse_position() - root_window.rect_global_position
		else:
			drag_position = null
	if (event is InputEventMouseMotion and drag_position):
		root_window.rect_global_position = get_global_mouse_position() - drag_position
		emit_signal("window_moved")
