extends Node2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func _process(delta):
	if (Input.is_action_just_pressed("disable_mouse") == true):
		$FreeMouse.visible = false;
		$PhysicsMouse.set_reset_physics(true)
	elif (Input.is_action_just_pressed("enable_mouse") == true):
		$PhysicsMouse.visible = false;
		$FreeMouse.visible = true;
