extends Spatial

var time : float
var theta_offset : float
var rot : Vector3
var rot_amplitude = deg2rad(23.5)

var speed = 8
var velocity : Vector3 = Vector3()


func _physics_process(delta):
	self.translate(velocity)
#	self.rotate_x(rot.x)
	
	time = float(OS.get_ticks_msec())
	theta_offset = time / 2048
	
	#Translation
	velocity.x = -speed * sin(theta_offset + PI) * delta / 2.0
	#Rotation
	rot.x = -rot_amplitude * sin(theta_offset + PI) * delta / 2.0
	
#	$Mesh.set_translation(velocity)
	$Wood.set_translation(velocity)
	$Metal.set_translation(velocity)








