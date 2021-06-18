extends "res://Scripts/state_machine/state_default.gd"


#Input Variables
var gyro_sensitivity = 0.1

#Camera View Variables
var camera_angle : Vector3

#Node Storage
onready var Body = owner.get_node("Body")
onready var Anim_Player = owner.get_node("AnimationPlayer")


#Initializes state, changes animation, etc
func enter():
	return


#Cleans up state, reinitializes values like timers
func exit():
	return


#Creates output based on the input event passed in
func handle_input(_event):
	return


func handle_ai_input():
	return


#Acts as the _process method would
func update(_delta):
	return


func _on_animation_finished(_anim_name):
	return


###INPUT FUNCTIONS###
func get_joystick_input_l():
	var input_x = Input.get_joy_axis(0, 0)
	var input_y = Input.get_joy_axis(0, 1)
	
	return Vector2(input_x, input_y)



func get_joystick_input_r():
	pass


#Currently unsupported
#func get_gyro_input_l():
#	pass


#Takes from betterjoy gyrotomouse
func get_gyro_input_r(event):
	var input_gyro = event.get_relative() * gyro_sensitivity
	
	return(input_gyro)
