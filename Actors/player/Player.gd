extends KinematicBody

#Input Variables
var gyro_sensitivity = 0.1

#Movement Variables
var speed_full = 24
var accel = 2
var deaccel = 1
var velocity : Vector3
var weight = 4.0
var gravity = -9.8

#Direction Variables
var camera_angle : Vector2

#Node Storage
var Raycast : Node
var Body : Node

func _ready():
	for child in self.get_children():
		if child.name == "Body":
			Body = child
		if child.name == "RayCast":
			Raycast = child


func _input(event):
	if Input.is_action_pressed("aim_right"):
		if event is InputEventMouseMotion and event.get_device() == 0:
			move_raycast(event)


func _process(delta):
	velocity = move_player(velocity, delta)
	velocity = move_and_slide(velocity, Vector3(0, 1, 0), true, 4, deg2rad(50))


func move_player(current_velocity, delta):
	var input : Vector2
	var input_direction : Vector2
	var velocity : Vector3
	
	input = get_joystick_input_l()
	
	#Get direction
	input_direction = input.normalized().rotated(-camera_angle.y)
	
	velocity = calc_velocity(input_direction, current_velocity, delta)
	
	if input.length() > 0:
		rotate_to_direction(input_direction)
	
	return(velocity)


func calc_velocity(input_direction, current_velocity, delta):
	#Velocity
	velocity.x = input_direction.x * speed_full
	velocity.z = input_direction.y * speed_full
	
	velocity.y = current_velocity.y + (gravity * weight * delta)
	
	return velocity


func rotate_to_direction(direction): #Direction should be normalized
	var rot_final = rad2deg(Vector2(0, 1).angle_to(-direction))
	
	Body.rotation_degrees.y = -rot_final
	Raycast.rotation_degrees.y = -rot_final


func move_raycast(event):
	var input_change = get_gyro_input_r(event) #this input is relative to last movement
	
	var angle_change = Vector2(-input_change.y, -input_change.x)
	
	Raycast.rotation_degrees.x = Raycast.get_rotation_degrees().x + angle_change.x 
	Raycast.rotation_degrees.y = Raycast.get_rotation_degrees().y + angle_change.y
	


func get_joystick_input_l():
	var input_x = Input.get_joy_axis(0, 0)
	var input_y = Input.get_joy_axis(0, 1)
	
	return Vector2(input_x, input_y)


#This would be part of camera script
func get_joystick_input_r():
	pass


#Currently unsupported
func get_gyro_input_l():
	pass


#Takes from betterjoy gyrotomouse
func get_gyro_input_r(event):
	var input_gyro = event.get_relative() * gyro_sensitivity
	
	return(input_gyro)


func _on_Camera_Rig_camera_angle_changed(angle):
	camera_angle = angle
