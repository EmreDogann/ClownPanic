extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var time = OS.get_datetime()
	var finalString = ""
	finalString += str(time.get("hour") % 12)
	finalString += ":" + str(time.get("minute"))
	
	if (time.get("hour") > 12):
		finalString += " PM"
	else:
		finalString += " AM"
	
	self.text = finalString
