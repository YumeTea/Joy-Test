extends Spatial

var origin : Vector3
var time : float
var theta_offset : float
var offset : Vector3
var amplitude = 16



func _ready():
	origin = self.translation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time = float(OS.get_ticks_msec())
	theta_offset = time / 2048
	
	offset.x = (-amplitude / 2) + (amplitude * sin(theta_offset))
	
	self.translation.x = origin.x + offset.x
