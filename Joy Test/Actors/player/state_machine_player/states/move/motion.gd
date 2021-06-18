extends "res://Actors/player/state_machine_player/states/shared/shared.gd"


#Initialized values storage
var initialized_values : Dictionary


#Movement Variables
var speed_full = 24
var accel = 2
var deaccel = 1
var weight = 4.0
var gravity = -9.8

var velocity : Vector3


#Initializes state, changes animation, etc
func enter():
	return


#Cleans up state, reinitializes values like timers
func exit():
	return


#Creates output based on the input event passed in
func handle_input(_event):
	return


#Acts as the _process method would
func update(delta):
	velocity = owner.move_and_slide_with_snap(velocity, Vector3(0, -0.5, 0), Vector3(0, 1, 0), true, 4, deg2rad(50))


func _on_animation_finished(_anim_name):
	return


#Stores certain values of the current state to be transferred to the next state
#Called from main state machine
func store_initialized_values(init_values_dic):
	for value in init_values_dic:
		init_values_dic[value] = self[value]


func connect_player_signals():
	owner.get_node("Camera_Rig").connect("camera_angle_changed", self, "_on_Camera_Rig_camera_angle_changed")


func disconnect_player_signals():
	owner.get_node("Camera_Rig").disconnect("camera_angle_changed", self, "_on_Camera_Rig_camera_angle_changed")


###SIGNAL FUNCTIONS###
func _on_Camera_Rig_camera_angle_changed(angle):
	camera_angle = angle





