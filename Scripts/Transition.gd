extends CanvasLayer

func _ready() -> void:
	transition()

func transition():
	get_node("../AnimationPlayer").play("fade_from_black")
