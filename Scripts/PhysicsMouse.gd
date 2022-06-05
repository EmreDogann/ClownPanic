extends RigidBody2D

signal on_mouse_collide()

var direction = Vector2(0.0, 0.0)
var speedAccumulation: float = 0.0
var speed: float = 0.0
var directionAccumulation: Vector2 = Vector2(0.0, 0.0)
var previous_mouse_pos: Vector2 = Vector2(0.0, 0.0)

var frame = 0
var maxFrameBuffer = 5

var rigidbody_origin = Vector2(0.0, 0.0)
var reset_physics = false
#var push_mouse = false;
#
#var timerCooldown = 0.05
#var timer = timerCooldown

var rng = RandomNumberGenerator.new()
var mouseSpriteNode: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	mouseSpriteNode = get_parent().get_node("MouseSprite")
	rigidbody_origin = self.position
	rng.randomize()
	
	connect("on_mouse_collide", get_tree().root.get_node("Node2D/AudioManager"), "mouse_collided")

#func _process(delta: float) -> void:
#	timer -= delta
#
#	if (timer <= 0.0):
#		timer = timerCooldown
#		push_mouse = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		var current_mouse_pos = self.get_global_mouse_position()
		
		if (frame % maxFrameBuffer != 0):
			directionAccumulation += current_mouse_pos - previous_mouse_pos
			speedAccumulation += current_mouse_pos.distance_to(previous_mouse_pos)
		else:
			direction = (directionAccumulation / maxFrameBuffer).normalized()
			speed = (speedAccumulation / maxFrameBuffer) * 1000
			
			directionAccumulation = Vector2(0,0)
			speedAccumulation = 0.0

		frame += 1
		previous_mouse_pos = current_mouse_pos

func set_reset_physics(reset):
	reset_physics = reset

func _integrate_forces(state: Physics2DDirectBodyState):
	if (reset_physics):
		var t = Transform2D(0, mouseSpriteNode.position + rigidbody_origin)
		state.set_transform(t)
		state.linear_velocity = Vector2()
		state.angular_velocity = 0
		
		var random_offset: Vector2
		var nums = [-1, 1] # Randomly pick between one of these two numbers.
		random_offset.x = rng.randf_range(5.0, 1.0) * nums[rng.randi() % nums.size()]
		random_offset.y = rng.randf_range(5.0, 1.0) * nums[rng.randi() % nums.size()]
		
		state.apply_impulse(random_offset, direction * speed)
		
		reset_physics = false
#	if (push_mouse):
#		state.apply_impulse(Vector2(0,0), direction * speed/ 10)
#		push_mouse = false


func _on_PhysicsMouse_body_entered(body: Node) -> void:
	emit_signal("on_mouse_collide")
