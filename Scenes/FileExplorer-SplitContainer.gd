extends HSplitContainer

onready var transparentMouseImage = preload("res://Images/TransparentPixel.png")

func _on_HSplitContainer_gui_input(event: InputEvent) -> void:
	Input.set_custom_mouse_cursor(transparentMouseImage)
