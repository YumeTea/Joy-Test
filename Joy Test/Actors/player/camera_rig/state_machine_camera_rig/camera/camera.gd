extends "res://Scripts/state_machine/state_default.gd"


'need to initialize can_aim flag'


signal camera_angle_changed(camera_angles)


##Input Variables
var input_stick_r : Vector2
var input_gyro_r : Vector2
var camera_input : Vector2

##Camera View Constants
var camera_angle_max = Vector3(deg2rad(90), deg2rad(360), deg2rad(360))

##Camera View Variables
var camera_sensitivity = 1.4
var camera_angle : Vector3

#Camera Flags
var can_aim = true
var is_aiming : bool

##Node Storage
onready var Camera_Rig = owner
onready var Pivot = owner.get_node("Pivot")
onready var Camera_Controller = owner.get_node("Pivot/Camera_Controller")
onready var Timer_Aim = owner.get_node("State_Machine_Camera/Camera/Timer_Aim")
onready var Camera_UI = owner.get_node("UI/Camera_UI")
onready var Tween_Camera = owner.get_node("Tween_Camera")
#Debug Node Storage??
onready var Pivot_Points = owner.get_node("Pivot_Points")
onready var Camera_Points = owner.get_node("Pivot/Camera_Points")
#State Machine
onready var State_Machine_Camera = owner.get_node("State_Machine_Camera")


#Initializes state, changes animation, etc
func enter():
	camera_angle_update()
	connect_local_signals()
	connect_external_signals()


#Cleans up state, reinitializes values like timers
func exit():
	disconnect_local_signals()
	disconnect_external_signals()


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
	elif !is_aiming and can_aim:
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
	
	##Angle limiting
	#X
	if abs(rot_pivot.x) > camera_angle_max.x:
		rot_pivot.x = camera_angle_max.x * sign(rot_pivot.x)
	
	Camera_Rig.set_rotation(rot_rig)
	Pivot.set_rotation(rot_pivot)
	
	camera_angle = camera_angle_update()


func camera_angle_update():
	var rot_rig : Vector3
	var rot_pivot : Vector3
	var camera_angle : Vector3
	
	rot_rig = Camera_Rig.get_rotation()
	rot_pivot = Pivot.get_rotation()
	camera_angle.x = rot_pivot.x
	camera_angle.y = rot_rig.y
	camera_angle.z = rot_pivot.z
	
	camera_angle = bound_angles(camera_angle)
	
	emit_signal("camera_angle_changed", camera_angle)
	
	return camera_angle


func set_camera_offset(pos_node_name):
	#This should be its own function
	var pivot_translation_current = Pivot.get_translation()
	var pivot_translation_final = Pivot_Points.get_node(pos_node_name).get_translation()
#	Pivot.set_translation(pivot_translation)
	
	Tween_Camera.interpolate_property(Pivot, "translation", pivot_translation_current, pivot_translation_final,  0.5, 5, 1, 0)
	
	var camera_translation_current = Camera_Controller.get_translation()
	var camera_translation_final = Camera_Points.get_node(pos_node_name).get_translation()
#	Camera_Controller.set_translation(camera_translation)
	
	Tween_Camera.interpolate_property(Camera_Controller, "translation", camera_translation_current, camera_translation_final,  0.5, 5, 1, 0)
	
	Tween_Camera.start()


###UTILITY FUNCTIONS###
#Bounds rotation angles to between -pi and pi
func bound_angles(angles_bound):
	var angles = angles_bound
	
	if angles.x > PI or angles.x < -PI:
		var co = ceil(floor(abs(angles.x) / PI) / 2.0) * 2.0
		angles.x = angles.x - ((co * PI) * sign(angles.x))
	if angles.y > PI or angles.y < -PI:
		var co = ceil(floor(abs(angles.y) / PI) / 2.0) * 2.0
		angles.y = angles.y - ((co * PI) * sign(angles.y))
	if angles.z > PI or angles.z < -PI:
		var co = ceil(floor(abs(angles.z) / PI) / 2.0) * 2.0
		angles.z = angles.z - ((co * PI) * sign(angles.z))
	
	return angles


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


func clear_gyro_input():
	input_gyro_r = Vector2(0,0)


###CAMERA FLAG FUNCTIONS###
func set_can_aim(value : bool):
	State_Machine_Camera.current_state.can_aim = value


func set_aiming(value : bool):
	State_Machine_Camera.current_state.is_aiming = value


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


###EXTERNAL SIGNAL COMMS###
func connect_external_signals():
	owner.owner.get_node("State_Machines/State_Machine_Move/Shared/Motion/In_Air/Wall_Jump").connect("restrict_aiming", self, "_on_restrict_aiming")


func disconnect_external_signals():
	owner.owner.get_node("State_Machines/State_Machine_Move/Shared/Motion/In_Air/Wall_Jump").disconnect("restrict_aiming", self, "_on_restrict_aiming")


###LOCAL SIGNAL FUNCTIONS###
func _on_Timer_Aim_timeout():
	set_aiming(false)


###EXTERNAL SIGNAL FUNCTIONS###
func _on_restrict_aiming(value : bool):
	State_Machine_Camera.current_state.set_can_aim(value)
	
	if value == false:
		State_Machine_Camera.current_state.set_aiming(false)
		
		if State_Machine_Camera.current_state.name == "Aim":
			emit_signal("state_switch", "default")
			return

