extends Control

onready var terminalTextNode = get_node("Window/VBoxContainer/Body/MarginContainer/ColorRect/RichTextLabel")

var closeWaitCooldown = 4.0
var closeWaitTimer = closeWaitCooldown
var closeTriggered = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (closeTriggered):
		closeWaitTimer -= delta
		
		if (closeWaitTimer <= 0.0):
			visible = true
			closeWaitTimer = closeWaitCooldown
			closeTriggered = false

func activate_terminal() -> void:
	terminalTextNode.begin_countdown()
	visible = true

func ambiguous_text() -> void:
	terminalTextNode.ambiguous_text()

func _on_Close_pressed() -> void:
	closeTriggered = true
	visible = false
