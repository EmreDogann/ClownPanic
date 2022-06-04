extends Control

signal begin_credits

onready var creditsNode = get_node("Window/VBoxContainer/Body/MarginContainer/ColorRect/RichTextLabel")

var closeWaitCooldown = 4.0
var closeWaitTimer = closeWaitCooldown
var closeTriggered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("begin_credits", creditsNode, "begin_credits")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (closeTriggered):
		closeWaitTimer -= delta
		
		if (closeWaitTimer <= 0.0):
			visible = true
			closeWaitTimer = closeWaitCooldown
			closeTriggered = false

func activate_terminal() -> void:
	emit_signal("begin_credits")
	visible = true

func _on_Close_pressed() -> void:
	closeTriggered = true
	visible = false
