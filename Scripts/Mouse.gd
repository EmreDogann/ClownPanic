extends Node2D

signal on_mouse_disable()
signal on_mouse_pressed()
signal on_mouse_released()

var mouseIcons: Array = [
	preload("res://Images/Cursor/XP/xp_arrow.png"),
	preload("res://Images/Cursor/XP/xp_diagonal1.png"),
	preload("res://Images/Cursor/XP/xp_diagonal2.png"),
	preload("res://Images/Cursor/XP/xp_horizontal.png"),
	preload("res://Images/Cursor/XP/xp_vertical.png"),
]

enum MouseMode {
	FREE
	PHYSICS
}

var mode = MouseMode.FREE
var prev_mouse_pos: Vector2

var original_tree_position: int

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	Input.set_custom_mouse_cursor(preload("res://Images/TransparentPixel.png"))
	
	original_tree_position = get_index()
	
	connect("on_mouse_disable", get_tree().root.get_node("Node2D/AudioManager"), "mouse_disabled")
	connect("on_mouse_pressed", get_tree().root.get_node("Node2D/AudioManager"), "mouse_pressed")
	connect("on_mouse_released", get_tree().root.get_node("Node2D/AudioManager"), "mouse_released")

func _process(delta: float) -> void:
	if (mode == MouseMode.PHYSICS):
		$MouseSprite.position = $PhysicsMouse.position
		$MouseSprite.rotation = $PhysicsMouse.rotation
	
#	get_viewport().warp_mouse(Vector2(600, 300))
	
func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("disable_mouse") == true):
		emit_signal("on_mouse_disable")
		$PhysicsMouse/CollisionPolygon2D.disabled = false
		
		$PhysicsMouse.set_reset_physics(true)
		yield(get_tree(), "physics_frame")
		yield(get_tree(), "physics_frame")
		mode = MouseMode.PHYSICS
		
		$MouseSprite/Sprite.position = -$PhysicsMouse.rigidbody_origin
	elif (Input.is_action_just_pressed("enable_mouse") == true):
		mode = MouseMode.FREE
		$MouseSprite/Sprite.position = Vector2(0, 0)
		$MouseSprite.rotation = 0
		
		$PhysicsMouse/CollisionPolygon2D.disabled = true
	elif (Input.is_action_just_pressed("mouse_left") == true):
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
		if (mode == MouseMode.FREE):
			$MouseSprite.position = self.get_global_mouse_position()

func _on_window_mouse_entered(isEdge: bool, type: int):
#	if (mode == MouseMode.FREE):
#		if (!isEdge):
#			if (type == 1 or type == 3):
#				$MouseSprite/Sprite.texture = mouseIcons[1] # Diagonal 1
#			else:
#				$MouseSprite/Sprite.texture = mouseIcons[2] # Diagonal 2
#		else:
#			if (type == 1):
#				$MouseSprite/Sprite.texture = mouseIcons[3] # Horizontal
#			else:
#				$MouseSprite/Sprite.texture = mouseIcons[4] # Vertical
#
#		$MouseSprite/Sprite.centered = true
	pass

func _on_window_mouse_exit():
#	$MouseSprite/Sprite.texture = mouseIcons[0] # Arrow
#	$MouseSprite/Sprite.centered = false
	pass
