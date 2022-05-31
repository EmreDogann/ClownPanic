extends RigidBody2D

var direction = Vector2(0.0, 0.0)
var speed: float = 0.0
var speedAccumulation = 0.0
var directionAccumulation: Vector2 = Vector2(0,0)
var previous_mouse_position = Vector2(0.0, 0.0)
var frame = 0
var maxFrameBuffer = 5

var rigidbody_origin = Vector2(0.0, 0.0)
var reset_physics = false
var show_mouse = false;

var rng = RandomNumberGenerator.new()
var mouseSpriteNode: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	mouseSpriteNode = get_parent().get_node("MouseSprite")
	rigidbody_origin = self.position
	rng.randomize()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var current_mouse_position = mouseSpriteNode.position
	
	if (frame % maxFrameBuffer != 0):
		directionAccumulation += current_mouse_position - previous_mouse_position
		speedAccumulation += current_mouse_position.distance_to(previous_mouse_position)
	else:
		direction = (directionAccumulation / maxFrameBuffer).normalized()
		speed = (speedAccumulation / maxFrameBuffer) * 1000
		
		directionAccumulation = Vector2(0,0)
		speedAccumulation = 0

	frame += 1
	previous_mouse_position = current_mouse_position

func set_reset_physics(reset):
	reset_physics = reset

func _integrate_forces(state: Physics2DDirectBodyState):
	if (reset_physics):
		var t = Transform2D(0, self.get_global_mouse_position() + rigidbody_origin)
		state.set_transform(t)
		state.linear_velocity = Vector2()
		state.angular_velocity = 0
		
		var random_offset: Vector2
		var nums = [-1, 1] # Randomly pick between one of these two numbers.
		random_offset.x = rng.randf_range(5.0, 1.0) * nums[rng.randi() % nums.size()]
		random_offset.y = rng.randf_range(5.0, 1.0) * nums[rng.randi() % nums.size()]
		
		state.apply_impulse(random_offset, direction * speed)
		
		reset_physics = false
