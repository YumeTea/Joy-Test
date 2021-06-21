extends "res://Scripts/state_machine/state_default.gd"


#Input Variables
var gyro_sensitivity = 0.1

#Camera View Variables
var camera_angles : Vector3
var camera_look_at_point : Vector3 #stores point that camera raycast is hitting

#Node Storage
onready var world = get_tree().current_scene
onready var Body = owner.get_node("Body")

onready var Timer_Aim = owner.get_node("State_Machines/State_Machine_Move/Timer_Aim")

onready var Anim_Player = owner.get_node("AnimationPlayer")

#Player Flags
var is_aiming : bool


#Initializes state, changes animation, etc
func enter():
	return


#Cleans up state, reinitializes values like timers
func exit():
	return


#Creates output based on the input event passed in
func handle_input(event):
	#Aim state exit handling
	if is_aiming:
		if Input.is_action_just_pressed("cancel"):
			set_aiming(false)
			Timer_Aim.stop()
		elif Input.is_action_just_released("aim_r"):
			if Timer_Aim.is_stopped():
				Timer_Aim.start(1)
		elif Input.is_action_just_pressed("aim_r"):
			if !Timer_Aim.is_stopped():
				Timer_Aim.stop()
	elif !is_aiming:
		if Input.is_action_just_pressed("aim_r"):
			set_aiming(true)
	


#Acts as the _process method would
func update(_delta):
	return


func _on_animation_finished(_anim_name):
	return


###PLAYER FLAG FUNCTIONS###
func set_aiming(value : bool):
	is_aiming = value


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
