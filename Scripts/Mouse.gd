extends Node2D

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

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.set_custom_mouse_cursor(preload("res://Images/TransparentPixel.png"))

func _process(delta: float) -> void:
	if (mode == MouseMode.PHYSICS):
		$MouseSprite.position = $PhysicsMouse.position
		$MouseSprite.rotation = $PhysicsMouse.rotation
	
#	get_viewport().warp_mouse(Vector2(600, 300))
	
func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("disable_mouse") == true):
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
		
	if (event is InputEventMouseMotion):
		if (mode == MouseMode.FREE):
			$MouseSprite.position = self.get_global_mouse_position()

func _on_window_mouse_entered(isEdge: bool, type: int):
	if (!isEdge):
		if (type == 1 or type == 3):
			$MouseSprite/Sprite.texture = mouseIcons[1] # Diagonal 1
		else:
			$MouseSprite/Sprite.texture = mouseIcons[2] # Diagonal 2
	else:
		if (type == 1):
			$MouseSprite/Sprite.texture = mouseIcons[3] # Horizontal
		else:
			$MouseSprite/Sprite.texture = mouseIcons[4] # Vertical
	
	$MouseSprite/Sprite.centered = true

func _on_window_mouse_exit():
	$MouseSprite/Sprite.texture = mouseIcons[0] # Arrow
	$MouseSprite/Sprite.centered = false
