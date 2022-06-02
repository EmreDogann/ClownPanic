extends CanvasLayer

func _ready() -> void:
	transition()

func transition():
	$AnimationPlayer.play("fade_from_black")
