extends "res://Actors/player/state_machine_player/shared/shared.gd"


signal velocity_change(velocity)


#Initialized values storage
var initialized_values : Dictionary

#Node Storage
onready var Timer_Action_L = owner.get_node("State_Machines/State_Machine_Action_L/Timer_Action_L")

#Action L Flags
var is_casting : bool
var is_charging : bool
var cast_ready : bool

#Animation Variables
var anim_current_instance : Node


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
	.update(delta)


func _on_animation_finished(_anim_name):
	return


#Stores certain values of the current state to be transferred to the next state
#Called from main state machine
func store_initialized_values(init_values_dic):
	for value in init_values_dic:
		init_values_dic[value] = self[value]


#ACTION FLAG FUNCTIONS
func set_casting(value):
	is_casting = value


func set_charging(value):
	is_charging = value


func set_cast_ready(value):
	cast_ready = value


###LOCAL SIGNAL COMMS###
func connect_local_signals():
	owner.get_node("AnimationPlayer").connect("animation_finished", self, "_on_animation_finished")
	owner.get_node("Camera_Rig").connect("camera_angle_changed", self, "_on_Camera_Rig_camera_angle_changed")
	owner.get_node("Camera_Rig").connect("camera_raycast_collision_changed", self, "_on_camera_raycast_collision_changed")
	
	owner.get_node("State_Machines/State_Machine_Move/Timer_Aim").connect("timeout", self, "_on_Timer_Aim_timeout")
	owner.get_node("State_Machines/State_Machine_Action_L/Timer_Action_L").connect("timeout", self, "_on_Timer_Action_L_timeout")


func disconnect_local_signals():
	owner.get_node("AnimationPlayer").disconnect("animation_finished", self, "_on_animation_finished")
	owner.get_node("Camera_Rig").disconnect("camera_angle_changed", self, "_on_Camera_Rig_camera_angle_changed")
	owner.get_node("Camera_Rig").disconnect("camera_raycast_collision_changed", self, "_on_camera_raycast_collision_changed")
	
	owner.get_node("State_Machines/State_Machine_Move/Timer_Aim").disconnect("timeout", self, "_on_Timer_Aim_timeout")
	owner.get_node("State_Machines/State_Machine_Action_L/Timer_Action_L").disconnect("timeout", self, "_on_Timer_Action_L_timeout")


func _on_Camera_Rig_camera_angle_changed(angles):
	camera_angles = angles


func _on_camera_raycast_collision_changed(collision_point):
	camera_look_at_point = collision_point


func _on_Timer_Aim_timeout():
	set_aiming(false)


func _on_Timer_Action_L_timeout():
	pass


