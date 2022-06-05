extends Control

signal crt_done

var crtSoundSubmitted: bool = false
var crtOpenDone: bool = false
var crtOpenTimer: float = 2.0

func _ready() -> void:
	connect("crt_done", get_tree().root.get_node("Disclamer/AudioManager"), "crt_done")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (!crtOpenDone):
		crtOpenTimer -= delta
		
		$Effect.material.set('shader_param/time', clamp(crtOpenTimer, 0 , 1))
		
		if (crtOpenTimer <= 0.0):
			crtOpenDone = true
		if (crtOpenTimer <= 0.8 and !crtSoundSubmitted):
			emit_signal("crt_done")
			crtSoundSubmitted = true
