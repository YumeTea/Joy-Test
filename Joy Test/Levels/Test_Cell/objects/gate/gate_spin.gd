extends Spatial

var rot : Vector3 = Vector3()
var rot_origin : Vector3
var rot_speed = 0.5


func _physics_process(delta):
	self.rotate_y(rot.y)
	
	rot = Vector3(0.0, rot_speed, 0.0) * delta
	
	$Wood.set_rotation(rot)
	$Metal.set_rotation(rot)












