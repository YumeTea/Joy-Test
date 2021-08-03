extends Spatial

var time : float
var theta_offset : float
var rot : Vector3
var rot_amplitude = deg2rad(20)


func _physics_process(delta):
	time = float(OS.get_ticks_msec())
	theta_offset = time / 2048
	
	#Rotation
	rot.x = rot_amplitude * sin(theta_offset + PI) * delta
	
	self.rotate_x(rot.x)
	
