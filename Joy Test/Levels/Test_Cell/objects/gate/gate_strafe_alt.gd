extends Spatial

var time : float
var theta_offset : float
var rot : Vector3
var rot_amplitude = deg2rad(23.5)

var speed = 8
var velocity : Vector3 = Vector3(0,0,0)


func _physics_process(delta):
	time = float(OS.get_ticks_msec())
	theta_offset = time / 2048
	
	#Translation
	velocity.x = -speed * sin(theta_offset + PI) * delta
	#Rotation
	rot.x = rot_amplitude * sin(theta_offset + PI) * delta
	
	self.translate(velocity)
#	self.rotate_x(rot.x)
	
#	print("gate velocity: " + str(velocity))
	
	self.force_update_transform()
	$Wood.force_update_transform()
	$Metal.force_update_transform()
