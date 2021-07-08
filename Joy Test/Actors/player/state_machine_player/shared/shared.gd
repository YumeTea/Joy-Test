extends "res://Scripts/state_machine/state_default.gd"


#Camera View Variables
var camera_angles : Vector3
var camera_look_at_point : Vector3 #stores point that camera raycast is hitting

#Node Storage
var attached_obj : Node

onready var world = get_tree().current_scene
onready var Body = owner.get_node("Body")
onready var Skel = owner.get_node("Body/Armature/Skeleton")

onready var Timer_Aim = owner.get_node("State_Machines/State_Machine_Move/Timer_Aim")

onready var AnimTree = owner.get_node("AnimationTree")
onready var Anim_Player = owner.get_node("AnimationPlayer")

#Debug Values
onready var Skel_rotation_init = Skel.get_rotation()

#Debug Nodes
onready var Debug_Point = owner.get_node("Debug_Point")
onready var Debug_Point2 = owner.get_node("Debug_Point2")

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
	var input : Vector2
	
	input.x = Input.get_joy_axis(0, 0)
	input.y = Input.get_joy_axis(0, 1)
	
	#Deadzone control
	if input.length() > ControllerValues.joystick_r_deadzone_outer:
		input = input.normalized()
	elif input.length() < ControllerValues.joystick_r_deadzone_inner:
		input = Vector2(0,0)
	else:
		var deadzone_interp : float
		var input_value : float
		var deadzone_range : float
		
		input_value = (ControllerValues.joystick_r_deadzone_outer - input.length())
		deadzone_range = (ControllerValues.joystick_r_deadzone_outer - ControllerValues.joystick_r_deadzone_inner)
		
		deadzone_interp = 1 - (input_value /  deadzone_range)
		
		input = Vector2(0,0).linear_interpolate(input.normalized(), deadzone_interp)
	
	return(input)


func get_joystick_input_r():
	var input : Vector2
	
	input.x = Input.get_joy_axis(0, 2)
	input.y = Input.get_joy_axis(0, 3)
	
	#Deadzone control
	if input.length() > ControllerValues.joystick_l_deadzone_outer:
		input = input.normalized()
	elif input.length() < ControllerValues.joystick_l_deadzone_inner:
		input = Vector2(0,0)
	else:
		var deadzone_interp : float
		var input_value : float
		var deadzone_range : float
		
		input_value = (ControllerValues.joystick_l_deadzone_outer - input.length())
		deadzone_range = (ControllerValues.joystick_l_deadzone_outer - ControllerValues.joystick_l_deadzone_inner)
		
		deadzone_interp = 1 - (input_value /  deadzone_range)
		
		input = Vector2(0,0).linear_interpolate(input.normalized(), deadzone_interp)
	
	return(input)


#Currently unsupported
#func get_gyro_input_l():
#	pass


#Takes from betterjoy gyrotomouse
func get_gyro_input_r(event):
	var input_gyro = event.get_relative() * ControllerValues.gyro_sensitivity
	
	return(input_gyro)


func get_facing_direction_horizontal(node : Node):
	var facing_direction : Vector3
	
	facing_direction = node.to_global(Vector3(0,0,-1)) - node.get_global_transform().origin
	facing_direction.y = 0.0
	facing_direction = facing_direction.normalized()
	
	
	return facing_direction

