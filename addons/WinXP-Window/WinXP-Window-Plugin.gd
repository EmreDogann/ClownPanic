tool
extends EditorPlugin

# Called when the plugin is enabled.
func _enter_tree():
	add_custom_type("WinXP-Window", "Node2D", preload("WindowScript.gd"), preload("res://Images/icon.png"))
	pass

# Called when plugin is disabled.
func _exit_tree():
	remove_custom_type("WinXP-Window")
	pass
