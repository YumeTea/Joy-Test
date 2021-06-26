extends Spatial

var rot_origin : Vector3
var time : float
var theta_offset : float
var offset : Vector3
var amplitude = deg2rad(-45)



func _ready():
	rot_origin = self.rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time = float(OS.get_ticks_msec())
	theta_offset = time / 2048
	
	offset.x = amplitude + (amplitude * sin(theta_offset))
	
	self.rotation.x = rot_origin.x + offset.x
	
