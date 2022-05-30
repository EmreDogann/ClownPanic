extends StaticBody2D

func _ready():
	pass

func _process(delta):
	var winSize = OS.get_window_size()
	var nodes = get_tree().get_nodes_in_group("ScreenColliders")
	
	# Taskbar Collider
	var shape = nodes[0].shape as RectangleShape2D
	nodes[0].position = Vector2(winSize.x/2.0, winSize.y-shape.extents.y)
	shape.extents.x = winSize.x/2.0
	
	# Left Collider
	shape = nodes[1].shape as RectangleShape2D
	nodes[1].position = Vector2(0-shape.extents.x, winSize.y/2.0)
	shape.extents.y = winSize.y/2.0 + 8
	
	# Top Collider
	shape = nodes[2].shape as RectangleShape2D
	nodes[2].position = Vector2(winSize.x/2.0, 0-shape.extents.y)
	shape.extents.x = winSize.x/2.0 + 8
	
	# Right Collider
	shape = nodes[3].shape as RectangleShape2D
	nodes[3].position = Vector2(winSize.x+shape.extents.x, winSize.y/2.0)
	shape.extents.y = winSize.y/2.0 + 8
