extends ColorRect

signal next_scene
# Path to the next scene to transition to
export(String, FILE, "*.tscn") var next_scene_path

# Reference to the _AnimationPlayer_ node
onready var _anim_player := $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("next_scene", get_node("../AudioManager"), "next_scene")

func _on_Quit_pressed() -> void:
	get_tree().quit()

func _on_Continue_pressed() -> void:
	# Plays the Fade animation and wait until it finishes
	_anim_player.play("Disclamer-FadeOut")
	emit_signal("next_scene")
	yield(_anim_player, "animation_finished")
	# Changes the scene
	get_tree().change_scene(next_scene_path)
