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

export(int) var MOUSE_SPEED = 100

var mode = MouseMode.FREE
var prev_mouse_pos: Vector2

func _ready():
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$MouseSprite/Sprite.position = -$PhysicsMouse.rigidbody_origin

func _process(delta: float) -> void:
	if (mode == MouseMode.PHYSICS):
		$MouseSprite.position = $PhysicsMouse.position
		$MouseSprite.rotation = $PhysicsMouse.rotation	
	
func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("disable_mouse") == true):
		$PhysicsMouse/CollisionPolygon2D.disabled = false
		$KinematicBody/CollisionPolygon2D.disabled = true
		
		$PhysicsMouse.set_reset_physics(true)
		yield(get_tree(), "physics_frame")
		yield(get_tree(), "physics_frame")
		mode = MouseMode.PHYSICS
		
#		$MouseSprite/Sprite.position = -$PhysicsMouse.rigidbody_origin
	elif (Input.is_action_just_pressed("enable_mouse") == true):
		mode = MouseMode.FREE
#		$MouseSprite/Sprite.position = Vector2(0, 0)
		$MouseSprite.rotation = 0
		
		$KinematicBody.position = Vector2(600,300)
		$KinematicBody/CollisionPolygon2D.disabled = false
		$PhysicsMouse/CollisionPolygon2D.disabled = true
		
	if (event is InputEventMouseMotion):
		if (mode == MouseMode.FREE):
			$KinematicBody.move_and_slide(event.relative * MOUSE_SPEED)
			$MouseSprite.position = $KinematicBody.position

#func _physics_process(delta):
#	var mouse_position = self.get_global_mouse_position()
#	if (mouse_position.distance_to(kinematicBody.position) > 0.0):
#		var direction_to_target = (mouse_position - kinematicBody.position).normalized() # We normalize the vector because we only care about the direction
#		kinematicBody.move_and_slide(direction_to_target * MOUSE_SPEED) # We multiply the direction by the speed

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
