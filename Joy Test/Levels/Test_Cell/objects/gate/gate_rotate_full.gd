extends Spatial

var rot_origin : Vector3
var rot_speed = 0.5

func _physics_process(delta):
	var speed = rot_speed * delta
	self.rotate_x(speed)
	self.rotate_y(speed)
	self.rotate_z(speed)
	
