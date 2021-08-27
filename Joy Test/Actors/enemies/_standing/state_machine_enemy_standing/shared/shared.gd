extends "res://Scripts/state_machine/state_default.gd"


signal restrict_aiming(value)


#Node Storage
var attached_obj : Node

onready var world = get_tree().current_scene
onready var Body = owner.get_node("Body")
onready var Skel = owner.get_node("Body/Armature/Skeleton")

onready var State_Machine_Move = owner.get_node("State_Machines/State_Machine_Move")
onready var State_Machine_Action_L = owner.get_node("State_Machines/State_Machine_Action_L")
onready var State_Machine_Action_R = owner.get_node("State_Machines/State_Machine_Action_R")

onready var Timer_Aim = owner.get_node("State_Machines/State_Machine_Move/Timer_Aim")

onready var AnimTree = owner.get_node("AnimationTree")
onready var Anim_Player = owner.get_node("AnimationPlayer")
onready var Tween_Player = owner.get_node("Tween_Player")

#Anim Node Refs
onready var AnimStateMachineActionL = owner.get_node("AnimationTree").get("parameters/BlendTreeActionL/StateMachineActionL/playback")
onready var AnimStateMachineActionR = owner.get_node("AnimationTree").get("parameters/BlendTreeActionR/StateMachineActionR/playback")

#Debug Values
onready var Skel_rotation_init = Skel.get_rotation()

#Player Flags
var arm_l_occupied : bool
var arm_r_occupied : bool
var can_aim = true
var is_aiming : bool


#Initializes state, changes animation, etc
func enter():
	return


#Cleans up state, reinitializes values like timers
func exit():
	return


#Creates output based on the input event passed in
func handle_input(event):
	return


#Acts as the _process method would
func update(_delta):
	return


func _on_animation_finished(_anim_name):
	return


###PLAYER FLAG FUNCTIONS###
func set_arm_l_occupied(value : bool):
	State_Machine_Move.current_state.arm_l_occupied = value
	State_Machine_Action_L.current_state.arm_l_occupied = value


func set_arm_r_occupied(value : bool):
	State_Machine_Move.current_state.arm_r_occupied = value
	State_Machine_Action_R.current_state.arm_r_occupied = value


func set_can_aim(value : bool):
	if value == false:
		State_Machine_Move.current_state.set_aiming(false)
		State_Machine_Action_L.current_state.set_aiming(false)
		State_Machine_Action_R.current_state.set_aiming(false)
		Timer_Aim.stop()
	
	State_Machine_Move.current_state.can_aim = value
	State_Machine_Action_L.current_state.can_aim = value
	State_Machine_Action_R.current_state.can_aim = value
	
	emit_signal("restrict_aiming", value)


func set_aiming(value : bool):
	is_aiming = value


###ANIMATION FUNCTIONS###
func anim_tree_play_anim(anim_name, anim_tree_node_playback):
	if !anim_tree_node_playback.is_playing():
		anim_tree_node_playback.start(anim_name)
	else:
		anim_tree_node_playback.travel(anim_name)


func get_facing_direction_horizontal(node : Node):
	var facing_direction : Vector3
	
	facing_direction = node.to_global(Vector3(0,0,-1)) - node.get_global_transform().origin
	facing_direction.y = 0.0
	facing_direction = facing_direction.normalized()
	
	
	return facing_direction

