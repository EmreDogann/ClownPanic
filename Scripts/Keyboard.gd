extends Node

signal on_key_pressed()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("on_key_pressed", get_tree().root.get_node("Node2D/AudioManager"), "key_pressed")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		emit_signal("on_key_pressed")
