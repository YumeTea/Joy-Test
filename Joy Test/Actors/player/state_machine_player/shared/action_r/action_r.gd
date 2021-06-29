extends "res://Actors/player/state_machine_player/shared/shared.gd"


signal jab_collision(collision)


#Initialized values storage
var initialized_values : Dictionary

#Jab Variables
var stick_point : Vector3
var attached_facing_dir : Vector3

#Animation Variables
var anim_pause_position : float

#Node Storage
onready var State_Machine_Action_R = owner.get_node("State_Machines/State_Machine_Action_R")
onready var Timer_Action_R = owner.get_node("State_Machines/State_Machine_Action_R/Timer_Action_R")

#Action R Bools
var hit_active : bool
var has_hit : bool


#Initializes state, changes animation, etc
func enter():
	connect_local_signals()


#Cleans up state, reinitializes values like timers
func exit():
	disconnect_local_signals()


#Creates output based on the input event passed in
func handle_input(event):
#	if Input.is_action_just_pressed("cancel"):
#		if is_aiming:
#			set_aiming(false)
#	if Input.is_action_just_pressed("aim_r"):
#		set_aiming(true)
	.handle_input(event)


#Acts as the _process method would
func update(_delta):
	return


func _on_animation_finished(_anim_name):
	return


###ACTION FLAG FUNCTIONS###
func set_hit_active(value):
	var current_state = State_Machine_Action_R.current_state
	current_state.hit_active = value

func set_hit(value):
	var current_state = State_Machine_Action_R.current_state
	current_state.has_hit = value


###STATE INITIALIZATION FUNCTIONS###
#Stores certain values of the current state to be transferred to the next state
#Called from main state machine
func store_initialized_values(init_values_dic):
	for value in init_values_dic:
		init_values_dic[value] = self[value]


###LOCAL SIGNAL COMMS###
func connect_local_signals():
	owner.get_node("AnimationPlayer").connect("animation_finished", self, "_on_animation_finished")
	owner.get_node("Camera_Rig").connect("camera_angle_changed", self, "_on_Camera_Rig_camera_angle_changed")
	owner.get_node("Camera_Rig").connect("camera_raycast_collision_changed", self, "_on_camera_raycast_collision_changed")
	
	owner.get_node("State_Machines/State_Machine_Move/Timer_Aim").connect("timeout", self, "_on_Timer_Aim_timeout")
	owner.get_node("State_Machines/State_Machine_Action_R/Timer_Action_R").connect("timeout", self, "_on_Timer_Action_R_timeout")


func disconnect_local_signals():
	owner.get_node("AnimationPlayer").disconnect("animation_finished", self, "_on_animation_finished")
	owner.get_node("Camera_Rig").disconnect("camera_angle_changed", self, "_on_Camera_Rig_camera_angle_changed")
	owner.get_node("Camera_Rig").disconnect("camera_raycast_collision_changed", self, "_on_camera_raycast_collision_changed")
	
	owner.get_node("State_Machines/State_Machine_Move/Timer_Aim").disconnect("timeout", self, "_on_Timer_Aim_timeout")
	owner.get_node("State_Machines/State_Machine_Action_R/Timer_Action_R").disconnect("timeout", self, "_on_Timer_Action_R_timeout")


func _on_Camera_Rig_camera_angle_changed(angles):
	camera_angles = angles


func _on_camera_raycast_collision_changed(collision_point):
	camera_look_at_point = collision_point


func _on_Timer_Aim_timeout():
	set_aiming(false)


func _on_Timer_Action_R_timeout():
	pass

