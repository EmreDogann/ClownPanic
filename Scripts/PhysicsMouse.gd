extends RigidBody2D

var direction = Vector2(0.0, 0.0)
var speed: float = 0.0
var speedAccumulation = 0.0
var previous_mouse_position = Vector2(0.0, 0.0)
var frame = 0

var rigidbody_origin = Vector2(0.0, 0.0)
var reset_physics = false
var show_mouse = false;

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (show_mouse):
		yield(get_tree(), "physics_frame")
		self.visible = true
		show_mouse = false
	
	var current_mouse_position = get_parent().get_node("FreeMouse").position
	direction = (current_mouse_position - previous_mouse_position).normalized()
	
	if (frame % 5 != 0):
		speedAccumulation += current_mouse_position.distance_to(previous_mouse_position)
	else:
		speed = (speedAccumulation / 5.0) * 1000
		speedAccumulation = 0

	frame += 1
	previous_mouse_position = current_mouse_position

func set_reset_physics(reset):
	reset_physics = reset

func _integrate_forces(state):
	if (reset_physics):
		var t = Transform2D(0, self.get_global_mouse_position())
		state.set_transform(t)
		state.linear_velocity = Vector2()
		state.angular_velocity = 0
		state.apply_impulse(Vector2(rng.randf_range(-5.0, 5.0), rng.randf_range(-5.0, 5.0)), direction * speed)
		
		reset_physics = false
		show_mouse = true
