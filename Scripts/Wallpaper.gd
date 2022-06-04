extends TextureRect

signal wallpaper_transition_finished

onready var wallpapers: Array = [
	# Level 1
	preload("res://Images/Wallpapers/Level 1/Image-1.png"),
	preload("res://Images/Wallpapers/Level 1/Image-2.png"),
	preload("res://Images/Wallpapers/Level 1/Image-3.png"),
	preload("res://Images/Wallpapers/Level 1/Image-4.png"),
	
	# Level 2
	preload("res://Images/Wallpapers/Level 2/Image-5.png"),
	preload("res://Images/Wallpapers/Level 2/Image-6.png"),
	preload("res://Images/Wallpapers/Level 2/Image-7.png"),
	preload("res://Images/Wallpapers/Level 2/Image-8.png"),
	
	# Level 3
	preload("res://Images/Wallpapers/Level 3/Image-9.png"),
	preload("res://Images/Wallpapers/Level 3/Image-10.png"),
	preload("res://Images/Wallpapers/Level 3/Image-11.png"),
	preload("res://Images/Wallpapers/Level 3/Image-12.png"),
	
	# Level 4
	preload("res://Images/Wallpapers/Level 4/Image-13.png"),
	preload("res://Images/Wallpapers/Level 4/Image-14.png"),
	preload("res://Images/Wallpapers/Level 4/Image-15.png"),
	preload("res://Images/Wallpapers/Level 4/Image-16.png"),
	
	# Level 5
	preload("res://Images/Wallpapers/Level 5/Image-17.png"),
	preload("res://Images/Wallpapers/Level 5/Image-18.png"),
	preload("res://Images/Wallpapers/Level 5/Image-19.png"),
	preload("res://Images/Wallpapers/Level 5/Image-20.png"),
]

var currentWallpaperIndex = 0
var transitionWallpaper: bool = false
var transitionTimerCooldown = 1.0
var transitionTimer = transitionTimerCooldown
var crossfadeValue = 0.0
onready var crossfadeMaterial = get_node("../Crossfade").material

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.texture = wallpapers[currentWallpaperIndex]
	connect("wallpaper_transition_finished", get_tree().root.get_node("Node2D/GameManager"), "wallpaper_transition_finished")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (transitionWallpaper):
		transitionTimer -= delta
		crossfadeValue += delta / transitionTimerCooldown
		
		crossfadeMaterial.set('shader_param/crossfade', crossfadeValue)

		if (transitionTimer <= 0.0):
			transitionTimer = transitionTimerCooldown
			crossfadeValue = 0.0
			transitionWallpaper = false
			emit_signal("wallpaper_transition_finished")
#
#func _input(event: InputEvent) -> void:
#	if (event is InputEventMouseButton and event.is_action_pressed("mouse_right")):
#		change_wallpaper()

func change_wallpaper() -> void:
	transitionWallpaper = true
	currentWallpaperIndex = clamp(currentWallpaperIndex + 1, 0, 19)
	crossfadeMaterial.set('shader_param/crossfade', 0.0)
	crossfadeMaterial.set('shader_param/textureOld', wallpapers[currentWallpaperIndex-1])
	crossfadeMaterial.set('shader_param/textureNew', wallpapers[currentWallpaperIndex])
