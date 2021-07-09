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

onready var AnimStateMachineMotion = owner.get_node("AnimationTree").get("parameters/BlendTreeMotion/StateMachineMotion/playback")


#Initializes state, changes animation, etc
func enter():
	connect_local_signals()


#Cleans up state, reinitializes values like timers
func exit():
	disconnect_local_signals()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	#Add external velocities (from outside this state machine)
	if velocity_ext != Vector3(0,0,0):
		velocity = add_velocity_ext(velocity, velocity_ext)
	
	#Add gravity
	velocity.y += (gravity * weight * delta)
	
	#Move player
	velocity = owner.move_and_slide_with_snap(velocity, snap_vector, Vector3(0, 1, 0), true, 4, deg2rad(50))
	
	.update(delta)


func _on_animation_finished(_anim_name):
	return


###MOTION FUNCTIONS###
#Used for adding jab recoil velocity
func add_velocity_ext(velocity, velocity_ext):
	var v_dot_ext : float
	var v_ext : Vector3
	var v_current : Vector3
	var v_new : Vector3
	
	v_ext = velocity_ext.normalized()
	v_current = velocity.normalized()
	
	v_dot_ext = max(0, v_ext.dot(v_current))
	
	v_new = velocity_ext + (velocity * v_dot_ext)
	
	clear_velocity_ext()
	
	return v_new


func clear_velocity_ext():
	velocity_ext = Vector3(0,0,0)


#Stores values of the current state in the top level state machine's dict, for transfer to another state
#Called from main state machine
func store_initialized_values(init_values_dic):
	for value in init_values_dic:
		init_values_dic[value] = self[value]


func connect_local_signals():
	owner.get_node("Camera_Rig").connect("camera_angle_changed", self, "_on_Camera_Rig_camera_angle_changed")
	owner.get_node("State_Machines/State_Machine_Action_L").connect("action_l_state_changed", self, "_on_State_Machine_Action_L_state_changed")
	owner.get_node("State_Machines/State_Machine_Action_R").connect("action_r_state_changed", self, "_on_State_Machine_Action_R_state_changed")
	owner.get_node("State_Machines/State_Machine_Action_R/Shared/Action_R/Jab").connect("jab_collision", self, "_on_jab_collision")
	owner.get_node("State_Machines/State_Machine_Action_R/Shared/Action_R/Jab_Aim").connect("jab_collision", self, "_on_jab_collision")
	
	owner.get_node("State_Machines/State_Machine_Move/Timer_Aim").connect("timeout", self, "_on_Timer_Aim_timeout")
	owner.get_node("State_Machines/State_Machine_Move/Timer_Move").connect("timeout", self, "_on_Timer_Move_timeout")
	
	owner.get_node("AnimationPlayer").connect("animation_finished", self, "_on_animation_finished")


func disconnect_local_signals():
	owner.get_node("Camera_Rig").disconnect("camera_angle_changed", self, "_on_Camera_Rig_camera_angle_changed")
	owner.get_node("State_Machines/State_Machine_Action_L").disconnect("action_l_state_changed", self, "_on_State_Machine_Action_L_state_changed")
	owner.get_node("State_Machines/State_Machine_Action_R").disconnect("action_r_state_changed", self, "_on_State_Machine_Action_R_state_changed")
	owner.get_node("State_Machines/State_Machine_Action_R/Shared/Action_R/Jab").disconnect("jab_collision", self, "_on_jab_collision")
	owner.get_node("State_Machines/State_Machine_Action_R/Shared/Action_R/Jab_Aim").disconnect("jab_collision", self, "_on_jab_collision")
	
	owner.get_node("State_Machines/State_Machine_Move/Timer_Aim").disconnect("timeout", self, "_on_Timer_Aim_timeout")
	owner.get_node("State_Machines/State_Machine_Move/Timer_Move").disconnect("timeout", self, "_on_Timer_Move_timeout")
	
	owner.get_node("AnimationPlayer").disconnect("animation_finished", self, "_on_animation_finished")


###LOCAL SIGNAL COMMS###
func _on_State_Machine_Action_L_state_changed(action_l_state):
	pass


func _on_State_Machine_Action_R_state_changed(action_r_state):
	pass


func _on_Timer_Aim_timeout():
	set_aiming(false)


func _on_Timer_Move_timeout():
	pass


func _on_jab_collision(collision):
	var col_material = collision["col_material"]
	
	##SOLID COLLISION
	if col_material in GlobalValues.collision_materials_solid:
		velocity_ext += collision["recoil_vel"]
	
	##SOFT COLLISION
	elif col_material in GlobalValues.collision_materials_soft:
		attached_obj = collision["collider"]
		emit_signal("state_switch", "stick_wall")


func _on_Camera_Rig_camera_angle_changed(angles):
	camera_angles = angles



