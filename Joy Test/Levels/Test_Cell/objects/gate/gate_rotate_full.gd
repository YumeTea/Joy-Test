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
	
	offset = Vector3(theta_offset, theta_offset, theta_offset)
	
	self.rotation = rot_origin + offset
	
