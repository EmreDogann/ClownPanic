extends Panel

var styleBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	styleBox = get_stylebox("panel")

func _on_Panel_mouse_entered() -> void:
	styleBox.bg_color = Color.mediumaquamarine

func _on_Panel_mouse_exited() -> void:
	styleBox.bg_color = Color.white
