extends Node2D

signal on_mouse_pressed()
signal on_mouse_released()

var prev_mouse_pos: Vector2

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	Input.set_custom_mouse_cursor(preload("res://Images/TransparentPixel.png"))
	
	connect("on_mouse_pressed", get_tree().root.get_node("Disclamer/AudioManager"), "mouse_pressed")
	connect("on_mouse_released", get_tree().root.get_node("Disclamer/AudioManager"), "mouse_released")
	
func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("mouse_left") == true):
		emit_signal("on_mouse_pressed")
	elif (Input.is_action_just_released("mouse_left") == true):
		emit_signal("on_mouse_released")
	elif (Input.is_action_just_pressed("mouse_right") == true):
		emit_signal("on_mouse_pressed")
	elif (Input.is_action_just_released("mouse_right") == true):
		emit_signal("on_mouse_released")
	elif (event is InputEventMouseButton and Input.is_action_just_pressed("ui_back") == true):
		emit_signal("on_mouse_pressed")
	elif (event is InputEventMouseButton and Input.is_action_just_released("ui_back") == true):
		emit_signal("on_mouse_released")
	elif (Input.is_action_just_pressed("ui_forward") == true):
		emit_signal("on_mouse_pressed")
	elif (Input.is_action_just_released("ui_forward") == true):
		emit_signal("on_mouse_released")
		
	if (event is InputEventMouseMotion):
		$MouseSprite.position = self.get_global_mouse_position()
