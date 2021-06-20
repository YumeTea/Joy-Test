extends "res://Scripts/state_machine/state_default.gd"

signal camera_angle_changed(camera_angles)


##Controller Variables
#Joystick
var joystick_l_deadzone_inner = 0.1
var joystick_l_deadzone_outer = 0.9
var joystick_r_deadzone_inner = 0.1
var joystick_r_deadzone_outer = 0.9

#Gyro
var gyro_sensitivity = 0.06

##Input Variables
var input_stick_r : Vector2
var input_gyro_r : Vector2
var camera_input : Vector2

##Camera View Variables
var camera_sensitivity = 1.4
var camera_angle : Vector3

##Node Storage
onready var Pivot = owner.get_node("Pivot")
onready var Camera_Pos = owner.get_node("Pivot/Camera_Pos")
onready var Camera_UI = owner.get_node("UI/Camera_UI")
#Debug Node Storage??
onready var Pivot_Points = owner.get_node("Pivot_Points")
onready var Camera_Points = owner.get_node("Pivot/Camera_Points")


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
	rotate_camera_pivot(camera_input)
	
	#Clear gyro input at the end of frame
	clear_gyro_input()


func _on_animation_finished(_anim_name):
	return


###CAMERA TRANSFORMATION FUNCTIONS###
func rotate_camera_pivot(input):
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


###UI FUNCTIONS###
func set_camera_ui(value):
	var anim_player = Camera_UI.get_node("AnimationPlayer")
	var crosshair_fade_anim = "crosshair_fade"
	
	if value == true:
		if anim_player.is_playing():
			if anim_player.get_current_animation() == crosshair_fade_anim:
				anim_player.play(crosshair_fade_anim, -1, 1.0)
		else:
			anim_player.play(crosshair_fade_anim, -1, 1.0, false)
	elif value == false:
		if anim_player.is_playing():
			if anim_player.get_current_animation() == crosshair_fade_anim:
				anim_player.play(crosshair_fade_anim, -1, -1.0)
		else:
			anim_player.play(crosshair_fade_anim, -1, -1.0, true)


###STATE MACHINE FUNCTIONS###
#Stores values of the current state in the top level state machine's dict, for transfer to another state
#Called from main state machine
func store_initialized_values(init_values_dic):
	for value in init_values_dic:
		init_values_dic[value] = self[value]


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
	if input.length() > joystick_l_deadzone_outer:
		input = input.normalized()
	elif input.length() < joystick_l_deadzone_inner:
		input = Vector2(0,0)
	
	return(input)


#Currently unsupported
#func get_gyro_input_l():
#	pass


#Takes from betterjoy gyrotomouse
func get_gyro_input_r(event):
	var input_gyro = event.get_relative() * gyro_sensitivity
	
	return(input_gyro)


func clear_gyro_input():
	input_gyro_r = Vector2(0,0)





