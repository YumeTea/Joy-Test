extends "res://Actors/player/state_machine_player/shared/shared.gd"


signal jab_collision(collision)


#Initialized values storage
var initialized_values : Dictionary

#Jab Variables
var stick_point : Vector3
var attached_facing_dir : Vector3

#Animation Variables
var anim_pause_position : float

#Pose Nodes/Variables
onready var RightArmController = owner.get_node("Body/Armature/Skeleton/RightArmController")
onready var RightArmController_idx = Skel.find_bone("RightArmController")
onready var RightArmController_default = owner.get_node("Body/Armature/Skeleton/TorsoController/RightArmController_default")
onready var RightArmController_offset = owner.get_node("Body/Armature/Skeleton/UpperChestBone/RightArmController_offset")

#Node Storage
onready var Timer_Action_R = owner.get_node("State_Machines/State_Machine_Action_R/Timer_Action_R")

#Anim Node Refs
onready var AnimSeekActionR = "parameters/BlendTreeActionR/SeekActionR/seek_position"

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
	.handle_input(event)


#Acts as the _process method would
func update(delta):
#	anchor_arm_r_transform()
	pass


func _on_animation_finished(_anim_name):
	return


###ACTION FLAG FUNCTIONS###
func set_hit_active(value : bool):
	var current_state = State_Machine_Action_R.current_state
	current_state.hit_active = value

func set_hit(value : bool):
	var current_state = State_Machine_Action_R.current_state
	current_state.has_hit = value


###POSE FUNCTIONIS###
func rotate_arm_r(rotation : Vector3):
	var look_at_point : Vector3
	var body_rotation : Vector3
	var pose : Transform
	
	body_rotation = Body.get_rotation()
	
	#Calc arm rotation amount and clamp to limit
	var rot : Vector3 = Vector3()
	rot.x = rotation.x - body_rotation.x
	rot.y = rotation.y - body_rotation.y
	rot.x = clamp(rot.x, -arm_r_rot_max, arm_r_rot_max)
	rot.y = clamp(rot.y, -arm_r_rot_max, arm_r_rot_max)
	
	#Orient look at point
	look_at_point = Vector3(0,0,-1).rotated(Vector3(1,0,0), rot.x)
	look_at_point = look_at_point.rotated(Vector3(0,1,0), rot.y)
	
	#Create custom pose
	pose.origin = Vector3(0,0,0)
	pose.basis = Basis(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1))
	
	pose = pose.looking_at(look_at_point, Vector3(0,1,0))
	
	#Put controller bone origin back where it was
	pose.origin = Skel.get_bone_custom_pose(RightArmController_idx).origin
	
	#Apply custom pose
	Skel.set_bone_custom_pose(RightArmController_idx, pose)


func reset_custom_pose_arm_r():
	var transform : Transform
	
	transform.origin = Vector3(0,0,0)
	transform.basis = Basis(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1))
	
	Skel.set_bone_custom_pose(RightArmController_idx, transform)


func anchor_arm_r_transform():
	var pose : Transform
	
	pose = Skel.get_bone_custom_pose(RightArmController_idx)
	
	pose.origin =  (RightArmController_offset.get_global_transform().origin - RightArmController_default.get_global_transform().origin)
	pose.origin = pose.origin.rotated(Vector3(0,1,0), -Body.get_rotation().y)
	
	Skel.set_bone_custom_pose(RightArmController_idx, pose)


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

