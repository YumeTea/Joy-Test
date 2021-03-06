extends "res://Actors/enemies/_standing/state_machine_enemy_standing/shared/shared.gd"


signal velocity_change(velocity)


#Initialized values storage
var initialized_values : Dictionary

#Inventory Variables
var current_spell : Resource

#Spell Variables
var charge_anim_scene : Resource
var spell_projectile : Resource

#Pose Variables
onready var LeftArmController_idx = Skel.find_bone("LeftArmController")

#Node Storage
onready var Timer_Action_L = owner.get_node("State_Machines/State_Machine_Action_L/Timer_Action_L")

onready var AnimSeekActionL = "parameters/BlendTreeActionL/SeekActionL/seek_position"

#Pose Nodes/Variables
onready var LeftArmController = owner.get_node("Body/Armature/Skeleton/LeftArmController")
onready var LeftArmController_default = owner.get_node("Body/Armature/Skeleton/TorsoController/LeftArmController_default")
onready var LeftArmController_offset = owner.get_node("Body/Armature/Skeleton/LeftShoulderBone/LeftArmController_offset")

#Action L Flags
var is_casting : bool
var is_charging : bool
var cast_ready : bool
var cast : bool

#Animation Variables
var charging_spell_instance : Node


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
	pass


func _on_animation_finished(anim_name):
	._on_animation_finished(anim_name)


#Stores certain values of the current state to be transferred to the next state
#Called from main state machine
func store_initialized_values(init_values_dic):
	for value in init_values_dic:
		init_values_dic[value] = self[value]


#ACTION FLAG FUNCTIONS
func set_casting(value : bool):
	var current_state = State_Machine_Action_L.current_state
	current_state.is_casting = value


func set_charging(value : bool):
	var current_state = State_Machine_Action_L.current_state
	current_state.is_charging = value


func set_cast_ready(value : bool):
	var current_state = State_Machine_Action_L.current_state
	current_state.cast_ready = value


func set_cast(value : bool):
	var current_state = State_Machine_Action_L.current_state
	current_state.cast = value


#POSE FUNCTIONS#
func reset_custom_pose_arm_l():
	var transform : Transform
	
	transform.origin = Vector3(0,0,0)
	transform.basis = Basis(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1))
	
	Skel.set_bone_custom_pose(LeftArmController_idx, transform)


func anchor_arm_l_transform():
	var pose : Transform
	
	pose = Skel.get_bone_custom_pose(LeftArmController_idx)
	
	pose.origin =  (LeftArmController_offset.get_global_transform().origin - LeftArmController_default.get_global_transform().origin)
	pose.origin = pose.origin.rotated(Vector3(0,1,0), -Body.get_rotation().y)
	
	Skel.set_bone_custom_pose(LeftArmController_idx, pose)


###LOCAL SIGNAL COMMS###
func connect_local_signals():
	owner.get_node("AnimationPlayer").connect("animation_finished", self, "_on_animation_finished")
	
	owner.get_node("State_Machines/State_Machine_Move/Timer_Aim").connect("timeout", self, "_on_Timer_Aim_timeout")
	owner.get_node("State_Machines/State_Machine_Action_L/Timer_Action_L").connect("timeout", self, "_on_Timer_Action_L_timeout")


func disconnect_local_signals():
	owner.get_node("AnimationPlayer").disconnect("animation_finished", self, "_on_animation_finished")
	
	owner.get_node("State_Machines/State_Machine_Move/Timer_Aim").disconnect("timeout", self, "_on_Timer_Aim_timeout")
	owner.get_node("State_Machines/State_Machine_Action_L/Timer_Action_L").disconnect("timeout", self, "_on_Timer_Action_L_timeout")


func _on_Timer_Aim_timeout():
	set_aiming(false)


func _on_Timer_Action_L_timeout():
	pass


