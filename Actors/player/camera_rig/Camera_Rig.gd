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
	
	self.rotation_degrees.x = angle_init
	
	camera_angle_update()


func _process(delta):
	var input : Vector2
	
	input = get_joystick_input_r()
	
	if input.length() > 0:
		move_camera(input)
	
	


func move_camera(input):
	var angle_change : Vector2
	
	angle_change = Vector2(-input.y, -input.x) * camera_sensitivity
	
	self.rotation_degrees.x += angle_change.x
	self.rotation_degrees.y += angle_change.y
	
	camera_angle_update()


func camera_angle_update():
	var camera_angle = Vector2(deg2rad(self.rotation_degrees.x), deg2rad(self.rotation_degrees.y))
	
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




