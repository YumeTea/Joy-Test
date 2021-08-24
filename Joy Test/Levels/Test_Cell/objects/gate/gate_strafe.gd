extends Spatial


export var move_dir : Vector3
export var speed_peak : float

var time : float
var theta_offset : float
var rot : Vector3
var rot_amplitude = deg2rad(23.5)

var velocity : Vector3 = Vector3()


func _ready():
	move_dir = move_dir.normalized()


func _physics_process(delta):
	self.global_translate(velocity)
#	self.rotate_x(rot.x)
	
	time = float(OS.get_ticks_msec())
	theta_offset = time / 2048
	
	#Translation
	velocity = move_dir * -speed_peak * sin(theta_offset + PI) * delta
	#Rotation
	rot.x = -rot_amplitude * sin(theta_offset + PI) * delta
	
#	$Mesh.set_translation(velocity)
	$Wood.set_translation(Vector3(0.0, velocity.y, 0.0))
	$Metal.set_translation(Vector3(0.0, velocity.y, 0.0))








