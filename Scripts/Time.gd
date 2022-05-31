# First Script!
extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var time = OS.get_datetime()
	
	# Add a leading zero to the minute.
	var finalString = "%d:%02d" % [time.get("hour") % 12, time.get("minute")]
	
	if (time.get("hour") > 12):
		finalString += " PM"
	else:
		finalString += " AM"
	
	self.text = finalString
