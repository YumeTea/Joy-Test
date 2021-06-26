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

#Camera Bools
var is_aiming : bool

##Node Storage
onready var Camera_Rig = owner
onready var Pivot = owner.get_node("Pivot")
onready var Camera_Pos = owner.get_node("Pivot/Camera_Pos")
onready var Timer_Aim = owner.get_node("State_Machine_Camera/Camera/Timer_Aim")
onready var Camera_UI = owner.get_node("UI/Camera_UI")
onready var Tween_Camera = owner.get_node("Tween_Camera")
#Debug Node Storage??
onready var Pivot_Points = owner.get_node("Pivot_Points")
onready var Camera_Points = owner.get_node("Pivot/Camera_Points")


#Initializes state, changes animation, etc
func enter():
	camera_angle_update()
	connect_local_signals()


#Cleans up state, reinitializes values like timers
func exit():
	disconnect_local_signals()


#Creates output based on the input event passed in
func handle_input(_event):
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
func update(delta):
	rotate_camera(camera_input)
	
	#Clear gyro input at the end of frame
	clear_gyro_input()


func _on_animation_finished(_anim_name):
	return


###CAMERA TRANSFORMATION FUNCTIONS###
func rotate_camera(input):
	var angle_change : Vector3
	var rot_rig : Vector3
	var rot_pivot
	
	angle_change = Vector3(deg2rad(-input.y), deg2rad(-input.x), 0) * camera_sensitivity
	
	rot_rig = Camera_Rig.get_rotation()
	rot_pivot = Pivot.get_rotation()
	rot_pivot.x += angle_change.x
	rot_rig.y += angle_change.y
	
	Camera_Rig.set_rotation(rot_rig)
	Pivot.set_rotation(rot_pivot)
	
	camera_angle_update()


func camera_angle_update():
	var rot_rig : Vector3
	var rot_pivot : Vector3
	var camera_angle : Vector3
	
	rot_rig = Camera_Rig.get_rotation()
	rot_pivot = Pivot.get_rotation()
	camera_angle.x = rot_pivot.x
	camera_angle.y = rot_rig.y
	camera_angle.z = rot_pivot.z
	
	emit_signal("camera_angle_changed", camera_angle)


func set_camera_offset(pos_node_name):
	#This should be its own function
	var pivot_translation_current = Pivot.get_translation()
	var pivot_translation_final = Pivot_Points.get_node(pos_node_name).get_translation()
#	Pivot.set_translation(pivot_translation)
	
	Tween_Camera.interpolate_property(Pivot, "translation", pivot_translation_current, pivot_translation_final,  0.5, 5, 1, 0)
	
	var camera_translation_current = Camera_Pos.get_translation()
	var camera_translation_final = Camera_Points.get_node(pos_node_name).get_translation()
#	Camera_Pos.set_translation(camera_translation)
	
	Tween_Camera.interpolate_property(Camera_Pos, "translation", camera_translation_current, camera_translation_final,  0.5, 5, 1, 0)
	
	Tween_Camera.start()


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


###CAMERA FLAG FUNCTIONS###
func set_aiming(value):
	is_aiming = value


###STATE MACHINE FUNCTIONS###
#Stores values of the current state in the top level state machine's dict, for transfer to another state
#Called from main state machine
func store_initialized_values(init_values_dic):
	for value in init_values_dic:
		init_values_dic[value] = self[value]


###LOCAL SIGNAL COMMS###
func connect_local_signals():
	owner.get_node("State_Machine_Camera/Camera/Timer_Aim").connect("timeout", self, "_on_Timer_Aim_timeout")


func disconnect_local_signals():
	owner.get_node("State_Machine_Camera/Camera/Timer_Aim").disconnect("timeout", self, "_on_Timer_Aim_timeout")


func _on_Timer_Aim_timeout():
	set_aiming(false)





