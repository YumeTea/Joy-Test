extends Spatial


export var speed : float
onready var rot_speed = deg2rad(speed)

var rot = Vector3(0,0,0)


func _physics_process(delta):
	rot = Vector3(rot_speed, 0.0, 0.0) * delta
	
	self.set_rotation(rotation + rot)
	
	$Wood.set_rotation(rot)
