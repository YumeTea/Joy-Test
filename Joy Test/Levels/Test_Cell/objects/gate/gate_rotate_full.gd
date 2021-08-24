extends Spatial

var rot : Vector3 = Vector3()
var rot_origin : Vector3
var rot_speed = 0.5

func _physics_process(delta):
	self.rotate_x(rot.x)
	self.rotate_y(rot.y)
	self.rotate_z(rot.z)
	
	rot = Vector3(rot_speed, rot_speed, rot_speed) * delta
	
	$Wood.set_rotation(rot)
	$Metal.set_rotation(rot)
