extends Spatial

var origin : Vector3
var rot_origin : Vector3
var time : float
var theta_offset : float
var offset : Vector3
var rot_offset : Vector3
var amplitude = 16
var rot_amplitude = deg2rad(44)



func _ready():
	origin = self.translation
	rot_origin = self.rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time = float(OS.get_ticks_msec())
	theta_offset = time / 2048
	
	#Translation
	offset.x = (-amplitude / 2) + (amplitude * sin(theta_offset + PI))
	#Rotation
	rot_offset.x = rot_amplitude + (rot_amplitude * sin(theta_offset + PI))
	
	self.translation.x = origin.x + offset.x
	self.rotation.x = rot_origin.x + rot_offset.x
