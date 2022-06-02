# Adapted from: https://www.reddit.com/r/godot/comments/qngy05/how_can_i_resize_a_textedit_window_with_a_mouse/hjgnr8i/?utm_source=share&utm_medium=web2x&context=3
extends Panel

var Corner: PackedScene = preload("res://Debug/WindowResizeCorner.tscn")
var Edge: PackedScene = preload("res://Debug/WindowResizeEdge.tscn")
var grabPointInstances: Array

onready var debug_edge_pivots = [
	Vector2(0.5, 1.0), # Top
	Vector2(0.5, 0.0), # Bottom
	Vector2(0.0, 0.5), # Right
	Vector2(1.0, 0.5) # Left
]

export(bool) var enable_debug_view = false 
export(bool) var enable_resizing = true 

var grabbing = false
var grab_range_corner = 8.0
var grab_range_edge = 3.0
var edge_corner_separation = 5.0
var active_grab_point = Vector2()
onready var grab_points = [
	# Corners
	rect_position,  # Top Left
	rect_position + Vector2(rect_size.x,0), # Top Right
	rect_position + rect_size, # Bottom Right
	rect_position + Vector2(0,rect_size.y), # Bottom Left
	
	# Edges
	rect_position + Vector2(rect_size.x/2.0,0), # Top
	rect_position + Vector2(rect_size.x/2.0,rect_size.y), # Bottom
	rect_position + Vector2(rect_size.x,rect_size.y/2.0), # Right
	rect_position + Vector2(0,rect_size.y/2.0), # Left
	]
	
func update_grab_points():
	grab_points[0] = rect_global_position
	grab_points[1] = rect_global_position + Vector2(rect_size.x,0)
	grab_points[2] = rect_global_position + rect_size
	grab_points[3] = rect_global_position + Vector2(0,rect_size.y)
	
	grab_points[4] = rect_global_position + Vector2(rect_size.x/2.0,0)
	grab_points[5] = rect_global_position + Vector2(rect_size.x/2.0,rect_size.y)
	grab_points[6] = rect_global_position + Vector2(rect_size.x,rect_size.y/2.0)
	grab_points[7] = rect_global_position + Vector2(0,rect_size.y/2.0)
	
	for i in range(8):
		grabPointInstances[i].rect_global_position = grab_points[i]
		
		if (i > 3):
			# Change scaling direction if the point is on the top/bottom vs left/right
			if (i < 6):
				grabPointInstances[i].rect_scale = Vector2(rect_size.x/2.0 - (edge_corner_separation*2.0), grab_range_edge) * 2
			else:
				grabPointInstances[i].rect_scale = Vector2(grab_range_edge, rect_size.y/2.0 - (edge_corner_separation*2.0)) * 2

func _ready() -> void:
	var mouseRef = get_tree().get_nodes_in_group("Mouse")
	
	if (mouseRef.size() > 0):
		mouseRef = mouseRef[0]
	
	# Make Corners
	for i in range(4):
		var debugCorner: Panel = Corner.instance()
		debugCorner.name = "CornerDebug" + str(i)
		debugCorner.rect_global_position = grab_points[i]
		debugCorner.rect_scale = Vector2(grab_range_corner, grab_range_corner) * 2
		
		if (mouseRef):
			debugCorner.connect("mouse_entered", mouseRef, "_on_window_mouse_entered", [false, i])
			debugCorner.connect("mouse_exited", mouseRef, "_on_window_mouse_exit")
		
		if (enable_debug_view):
			debugCorner.get_stylebox("panel").draw_center = true
		add_child(debugCorner)
		
		grabPointInstances.append(debugCorner)
		
	# Make Edges
	for i in range(4):
		var debugEdge: Panel = Edge.instance()
		debugEdge.name = "EdgeDebug" + str(i)
		debugEdge.rect_global_position = grab_points[i + 4]
		
		# Change scaling direction if the point is on the top/bottom vs left/right
		if (i <= 1): # Top/Bottom
			debugEdge.rect_scale = Vector2(rect_size.x/2.0 - (edge_corner_separation*2.0), grab_range_edge) * 2
		else: # Left/Right
			debugEdge.rect_scale = Vector2(grab_range_edge, rect_size.y/2.0 - (edge_corner_separation*2.0)) * 2
		
		if (mouseRef):
			if (i <= 1): # Top/Bottom
				debugEdge.connect("mouse_entered", mouseRef, "_on_window_mouse_entered", [true, 0])
			else: # Left/Right
				debugEdge.connect("mouse_entered", mouseRef, "_on_window_mouse_entered", [true, 1])
			debugEdge.connect("mouse_exited", mouseRef, "_on_window_mouse_exit")
			
		debugEdge.rect_pivot_offset = debug_edge_pivots[i]
		
		if (enable_debug_view):
			debugEdge.get_stylebox("panel").draw_center = true
		add_child(debugEdge)

		grabPointInstances.append(debugEdge)

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left") and enable_resizing:
		for i in grab_points.size():
			# Check corner collisions
			if (i < 3):
				if event.position.distance_to(grab_points[i]) < grab_range_corner:
					Input.set_default_cursor_shape(Input.CURSOR_MOVE)
					mouse_default_cursor_shape = Control.CURSOR_MOVE
					active_grab_point = i
					grabbing = true
			else: # Check edge collisions
				var box = Rect2(grabPointInstances[i].rect_global_position, grabPointInstances[i].rect_scale)
				if box.has_point(event.position):
					Input.set_default_cursor_shape(Input.CURSOR_MOVE)
					mouse_default_cursor_shape = Control.CURSOR_MOVE
					active_grab_point = i
					grabbing = true
	if event.is_action_released("mouse_left"):
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
				mouse_default_cursor_shape = Control.CURSOR_ARROW
				grabbing = false
	if grabbing and event is InputEventMouseMotion and enable_resizing:
		var new_position: Vector2
		var new_size: Vector2
		
		if active_grab_point == 0:
			new_position += event.relative
			new_size += event.relative *-1
		elif active_grab_point == 1:
			new_position.y += event.relative.y
			new_size.y += event.relative.y *-1
			new_size.x += event.relative.x
		elif active_grab_point == 2:
			new_size += event.relative
		elif active_grab_point == 3:
			new_position.x += event.relative.x
			new_size.x += event.relative.x *-1
			new_size.y += event.relative.y
		elif active_grab_point == 4:
			new_position.y += event.relative.y
			new_size.y += event.relative.y *-1
		elif active_grab_point == 5:
			new_size.y += event.relative.y
		elif active_grab_point == 6:
			new_size.x += event.relative.x
		elif active_grab_point == 7:
			new_position.x += event.relative.x
			new_size.x += event.relative.x * -1
		
		# BUG: When overshooting the min size, the window awkwardly stops resizing. Need to handle the case of overshoot by clamping the values.
		# Don't resize the window if it will go below its minimum size
		if (rect_size.x + new_size.x >= rect_min_size.x):
				rect_position.x += new_position.x
				rect_size.x += new_size.x
		if (rect_size.y + new_size.y >= rect_min_size.y):
				rect_position.y += new_position.y
				rect_size.y += new_size.y
		
		update_grab_points()

func _on_Titlebar_window_moved() -> void:
	if (enable_resizing):
		update_grab_points()
