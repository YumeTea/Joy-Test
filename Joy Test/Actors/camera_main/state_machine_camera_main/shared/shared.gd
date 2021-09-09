extends "res://Scripts/state_machine/state_default.gd"


#Node Storage
onready var State_Machine_Camera_Main = owner.get_node("State_Machines/State_Machine_Camera_Main")


#Camera Tracking Vars
var camera_target : KinematicBody = null


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
func update(_delta):
	return


func _on_animation_finished(_anim_name):
	return


#Shared setter functions
func set_camera_target(node):
	State_Machine_Camera_Main.current_state.camera_target = node







