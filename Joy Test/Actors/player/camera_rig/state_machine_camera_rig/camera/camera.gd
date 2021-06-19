extends "res://Scripts/state_machine/state_default.gd"

signal camera_angle_changed(camera_angles)


##Controller Variables
#Joystick
var joystick_l_deadzone_inner = 0.1
var joystick_l_deadzone_outer = 0.9
var joystick_r_deadzone_inner = 0.1
var joystick_r_deadzone_outer = 0.9

#Gyro
var gyro_sensitivity = 0.1

##Input Variables
var input_r : Vector2

##Camera View Variables
var camera_sensitivity = 1.8
var camera_angle : Vector3

##Node Storage
onready var Pivot = owner.get_node("Pivot")


#Initializes state, changes animation, etc
func enter():
	camera_angle_update()


#Cleans up state, reinitializes values like timers
func exit():
	return


#Creates output based on the input event passed in
func handle_input(_event):
	return


#Acts as the _process method would
func update(delta):
	move_camera(input_r)


func _on_animation_finished(_anim_name):
	return


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


###INPUT FUNCTIONS###
func get_joystick_input_l():
	var input_x = Input.get_joy_axis(0, 0)
	var input_y = Input.get_joy_axis(0, 1)
	
	return Vector2(input_x, input_y)


#Perform deadzone control here
func get_joystick_input_r():
	var input : Vector2
	
	input.x = Input.get_joy_axis(0, 2)
	input.y = Input.get_joy_axis(0, 3)
	
	#Deadzone control
	if abs(input.x) < joystick_r_deadzone_inner:
		input.x = 0
	if abs(input.x) > joystick_r_deadzone_outer:
		input.x = 1.0 * sign(input.x)
	
	if abs(input.y) < joystick_r_deadzone_inner:
		input.y = 0
	if abs(input.y) > joystick_r_deadzone_outer:
		input.y = 1.0 * sign(input.y)
	
	return(input)


#Currently unsupported
#func get_gyro_input_l():
#	pass


#Takes from betterjoy gyrotomouse
func get_gyro_input_r(event):
	var input_gyro = event.get_relative() * gyro_sensitivity
	
	return(input_gyro)
