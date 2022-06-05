extends Panel

var characters = 'abcdefghijklmnopqrstuvwxyz'
onready var windowNameNode = get_node("VBoxContainer/Titlebar/HBoxContainer/MarginContainer2/Window Name")

var nameGenerateCooldown = 4.0
var nameGenerateTimer = nameGenerateCooldown

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	
	get_parent().rect_size = Vector2(rng.randi_range(200, 400), rng.randi_range(100, 400))
	get_parent().rect_position = Vector2(rng.randi_range(0, get_viewport_rect().size.x - get_parent().rect_size.x), rng.randi_range(0, get_viewport_rect().size.y - get_parent().rect_size.y))
	
	windowNameNode.text = generate_word(characters, 12)
	
func generate_word(chars, length) -> String:
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word
	
func _process(delta: float) -> void:
	nameGenerateTimer -= delta
	
	if (nameGenerateTimer <= 0.0):
		nameGenerateTimer = nameGenerateCooldown
		windowNameNode.text = generate_word(characters, rng.randi_range(0, 30))

func _on_Close_pressed() -> void:
	get_parent().queue_free()
