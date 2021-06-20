extends "res://Actors/player/state_machine_player/shared/shared.gd"


#Initialized values storage
var initialized_values : Dictionary


#Movement Variables
var speed_full = 24
var weight = 5.0
var gravity = -9.8
var velocity : Vector3
var velocity_ext : Vector3 #used for adding velocity applied from out of state machine scripts
var snap_vector : Vector3
var snap_vector_default = Vector3(0, -0.5, 0)

#Node Storage
onready var Timer_Move = owner.get_node("State_Machines/State_Machine_Move/Timer_Move")


#Initializes state, changes animation, etc
func enter():
	connect_local_signals()


#Cleans up state, reinitializes values like timers
func exit():
	disconnect_local_signals()


#Creates output based on the input event passed in
func handle_input(_event):
	return


#Acts as the _process method would
func update(delta):
	#Add external velocities (from outside this state machine)
	velocity += velocity_ext
	velocity_ext = Vector3(0,0,0)
	
	#Add gravity
	velocity.y += (gravity * weight * delta)
	
	#Move player
	velocity = owner.move_and_slide_with_snap(velocity, snap_vector, Vector3(0, 1, 0), true, 4, deg2rad(50))


func _on_animation_finished(_anim_name):
	return


#Stores values of the current state in the top level state machine's dict, for transfer to another state
#Called from main state machine
func store_initialized_values(init_values_dic):
	for value in init_values_dic:
		init_values_dic[value] = self[value]


func connect_local_signals():
	owner.get_node("Camera_Rig").connect("camera_angle_changed", self, "_on_Camera_Rig_camera_angle_changed")
	owner.get_node("State_Machines/State_Machine_Action_L").connect("action_l_state_changed", self, "_on_State_Machine_Action_L_state_changed")
	owner.get_node("State_Machines/State_Machine_Action_R").connect("action_r_state_changed", self, "_on_State_Machine_Action_R_state_changed")
	owner.get_node("State_Machines/State_Machine_Action_R/Shared/Action_R/Jab").connect("velocity_change", self, "_on_Jab_velocity_change")
	owner.get_node("State_Machines/State_Machine_Action_R/Shared/Action_R/Jab_Aim").connect("velocity_change", self, "_on_Jab_velocity_change")
	owner.get_node("State_Machines/State_Machine_Move/Timer_Move").connect("timeout", self, "_on_Timer_Move_timeout")


func disconnect_local_signals():
	owner.get_node("Camera_Rig").disconnect("camera_angle_changed", self, "_on_Camera_Rig_camera_angle_changed")
	owner.get_node("State_Machines/State_Machine_Action_L").disconnect("action_l_state_changed", self, "_on_State_Machine_Action_L_state_changed")
	owner.get_node("State_Machines/State_Machine_Action_R").disconnect("action_r_state_changed", self, "_on_State_Machine_Action_R_state_changed")
	owner.get_node("State_Machines/State_Machine_Action_R/Shared/Action_R/Jab").disconnect("velocity_change", self, "_on_Jab_velocity_change")
	owner.get_node("State_Machines/State_Machine_Action_R/Shared/Action_R/Jab_Aim").disconnect("velocity_change", self, "_on_Jab_velocity_change")
	owner.get_node("State_Machines/State_Machine_Move/Timer_Move").disconnect("timeout", self, "_on_Timer_Move_timeout")


###LOCAL SIGNAL COMMS###
func _on_State_Machine_Action_L_state_changed(action_l_state):
	pass


func _on_State_Machine_Action_R_state_changed(action_r_state):
#	if action_r_state.get_name() == "Jab":
#		action_r_state.connect("velocity_change", self, "_on_Jab_velocity_change")
#	else:
#		action_r_state.disconnect("velocity_change", self, "_on_Jab_velocity_change")
	pass


func _on_Timer_Move_timeout():
	set_aiming(false)


func _on_Jab_velocity_change(velocity):
	velocity_ext += velocity


func _on_Camera_Rig_camera_angle_changed(angles):
	camera_angles = angles



