extends "res://Scripts/state_machine/state_default.gd"


#Node Storage
onready var State_Machine_Camera_Main = owner.get_node("State_Machines/State_Machine_Camera_Main")


#Camera Tracking Vars
var camera_target : Node = null

#Camera Tracking Flags
var follow_on_input : bool = false


#Initializes state, changes animation, etc
func enter():
	connect_external_signals()
	return


#Cleans up state, reinitializes values like timers
func exit():
	disconnect_external_signals()
	return


#Creates output based on the input event passed in
func handle_input(_event):
	return


#Acts as the _process method would
func update(_delta):
	if follow_on_input:
		if Input.get_joy_axis(0,0) != 0.0:
			set_follow_on_input(false)
			emit_signal("state_switch", "player_follow")
			return
		elif Input.get_joy_axis(0,1) != 0.0:
			set_follow_on_input(false)
			emit_signal("state_switch", "player_follow")
			return
		elif Input.get_joy_axis(0,2) != 0.0:
			set_follow_on_input(false)
			emit_signal("state_switch", "player_follow")
			return
		elif Input.get_joy_axis(0,3) != 0.0:
			set_follow_on_input(false)
			emit_signal("state_switch", "player_follow")
			return


func _on_animation_finished(_anim_name):
	return


#Flag setter functions
func set_follow_on_input(value):
	State_Machine_Camera_Main.current_state.follow_on_input = value


#Shared setter functions
func set_camera_target(node):
	State_Machine_Camera_Main.current_state.camera_target = node


#Stores values of the current state in the top level state machine's dict, for transfer to another state
#Called from main state machine
func store_initialized_values(init_values_dic):
	for value in init_values_dic:
		init_values_dic[value] = self[value]


###EXTERNAL SIGNAL COMMS###
func connect_external_signals():
	if Global.get_player() != null:
		Global.get_player().connect("player_entered_gate", self, "_on_player_entered_gate")
	GameManager.connect("set_camera_main_state", self, "_on_set_camera_main_state")
	GameManager.connect("set_camera_follow_on_input", self, "_on_set_camera_follow_on_input")


func disconnect_external_signals():
	if Global.get_player() != null:
		Global.get_player().disconnect("player_entered_gate", self, "_on_player_entered_gate")
	GameManager.disconnect("set_camera_main_state", self, "_on_set_camera_main_state")
	GameManager.disconnect("set_camera_follow_on_input", self, "_on_set_camera_follow_on_input")


func _on_player_entered_gate(gate_node):
	emit_signal("state_switch", "fixed_track_player")


func _on_set_camera_main_state(state_name, transform):
	if transform != null:
		owner.set_global_transform(transform)
	emit_signal("state_switch", state_name)


func _on_set_camera_follow_on_input(flag):
	set_follow_on_input(flag)







