extends Spatial

signal camera_angle_changed(angle)


#Input Variables
var inner_deadzone = 0.1
var outer_deadzone = 0.9
var camera_sensitivity = 1.8


#Camera Variables
var angle_init = -25

#Node Storage
var Pivot : Spatial

func _ready():
	#Store Nodes
	for child in self.get_children():
		if child.name == "Pivot":
			Pivot = child
	
	#Put camera pivot at initial angle
#	Pivot.rotation_degrees.x = angle_init #can set this in editor
	
	camera_angle_update()


func _process(delta):
	var input : Vector2
	
	input = get_joystick_input_r()
	
	if input.length() > 0:
		move_camera(input)
	
	


func move_camera(input):
	var angle_change : Vector3
	var rot : Vector3
	
	angle_change = Vector3(-input.y, -input.x, 0) * camera_sensitivity
	
	rot = Pivot.get_rotation_degrees()
	rot.x += angle_change.x
	rot.y += angle_change.y
	
	Pivot.set_rotation_degrees(rot)
	
	camera_angle_update()


func camera_angle_update():
	var camera_angle : Vector3
	
	camera_angle = Pivot.get_rotation_degrees()
	camera_angle.x = deg2rad(camera_angle.x)
	camera_angle.y = deg2rad(camera_angle.y)
	camera_angle.z = deg2rad(camera_angle.z)
	
	emit_signal("camera_angle_changed", camera_angle)


#Perform deadzone control here
func get_joystick_input_r():
	var input : Vector2
	
	input.x = Input.get_joy_axis(0, 2)
	input.y = Input.get_joy_axis(0, 3)
	
	#Deadzone control
	if abs(input.x) < inner_deadzone:
		input.x = 0
	if abs(input.x) > outer_deadzone:
		input.x = 1.0 * sign(input.x)
	
	if abs(input.y) < inner_deadzone:
		input.y = 0
	if abs(input.y) > outer_deadzone:
		input.y = 1.0 * sign(input.y)
	
	return(input)




