extends "res://Actors/player/state_machine_player/shared/shared.gd"


signal velocity_change(velocity)


#Initialized values storage
var initialized_values : Dictionary

#Inventory Variables
var current_spell : Resource

#Spell Variables
var charge_anim_scene : Resource
var spell_projectile : Resource
var barrier_object : Resource
var barrier_instance : Node

#Pose Variables
onready var LeftArmController_idx = Skel.find_bone("LeftArmController")
var pose_blend_l : Transform
var blend_motionactionl : float

#Node Storage
onready var Spell_Origin = owner.get_node("Body/Armature/Skeleton/LeftHandBone/Spell_Origin")
onready var Barrier_Pivot = owner.get_node("Body/Barrier_Pivot")
onready var Barrier_Origin = owner.get_node("Body/Barrier_Pivot/Barrier_Origin")
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
	connect_external_signals()

#Cleans up state, reinitializes values like timers
func exit():
	disconnect_local_signals()
	disconnect_external_signals()


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


#ACTION L FLAG FUNCTIONS
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


func set_b_sliding(value : bool):
	var current_move_state = State_Machine_Move.current_state
	var current_actionl_state = State_Machine_Action_L.current_state
	current_move_state.is_b_sliding = value
	current_actionl_state.is_b_sliding = value


func set_override_input(value : bool):
	State_Machine_Action_L.current_state.override_input = value


###ACTION L VAR SETTER FUNCS###
func set_override_waypoint(node : Node):
	State_Machine_Action_L.current_state.override_waypoint = node


#BARRIER FUNCTIONS#
func rotate_barrier(rotation : Vector3, limit_rot : bool):
	var body_rotation : Vector3
	
	body_rotation = Body.get_rotation()
	
	var rot : Vector3 = Vector3()
	rot.x =  Vector2(0,1).rotated(body_rotation.x).angle_to(Vector2(0,1).rotated(rotation.x))
	rot.y = Vector2(0,1).rotated(body_rotation.y).angle_to(Vector2(0,1).rotated(rotation.y))
	
	if limit_rot:
		#Clamp rotation to max rotation difference to body rotation
		rot.x = clamp(rot.x, -arm_l_rot_max, arm_l_rot_max)
		rot.y = clamp(rot.y, -arm_l_rot_max, arm_l_rot_max)
	
	#Set barrier rotation
	Barrier_Pivot.rotation.x = rot.x
	Barrier_Pivot.rotation.y = rot.y


func reset_barrier_rotation():
	Barrier_Pivot.set_rotation(Vector3(0,0,0))


#POSE FUNCTIONS#
func rotate_arm_l(rotation : Vector3):
	var look_at_point : Vector3
	var body_rotation : Vector3
	var pose : Transform
	
	body_rotation = Body.get_rotation()
	
	#Calc arm rotation amount and clamp to limit
	var rot : Vector3 = Vector3()
	rot.x =  Vector2(0,1).rotated(body_rotation.x).angle_to(Vector2(0,1).rotated(rotation.x))
	rot.y = Vector2(0,1).rotated(body_rotation.y).angle_to(Vector2(0,1).rotated(rotation.y))
	rot.x = clamp(rot.x, -arm_l_rot_max, arm_l_rot_max)
	rot.y = clamp(rot.y, -arm_l_rot_max, arm_l_rot_max)
	
	#Orient look at point
	look_at_point = Vector3(0,0,-1).rotated(Vector3(1,0,0), rot.x)
	look_at_point = look_at_point.rotated(Vector3(0,1,0), rot.y)
	
	#Create custom pose
	pose.origin = Vector3(0,0,0)
	pose.basis = Basis(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1))
	
	pose = pose.looking_at(look_at_point, Vector3(0,1,0))
	
	#Put controller bone origin back where it was
	pose.origin = Skel.get_bone_custom_pose(LeftArmController_idx).origin
	
	#Apply custom pose
	Skel.set_bone_custom_pose(LeftArmController_idx, pose)


func reset_custom_pose_arm_l():
	var transform : Transform
	
	transform.origin = Vector3(0,0,0)
	transform.basis = Basis(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1))
	
	Skel.set_bone_custom_pose(LeftArmController_idx, transform)


func reset_custom_pose_rotation_arm_l():
	var transform : Transform
	
	transform.origin = Skel.get_bone_custom_pose(LeftArmController_idx).origin
	transform.basis = Basis(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1))
	
	Skel.set_bone_custom_pose(LeftArmController_idx, transform)


#Keeps arm bones attached to shoulder during move animations
func anchor_arm_l_transform():
	var pose : Transform
	
	pose = Skel.get_bone_custom_pose(LeftArmController_idx)
	
	pose.origin =  (LeftArmController_offset.get_global_transform().origin - LeftArmController_default.get_global_transform().origin)
	pose.origin = pose.origin.rotated(Vector3(0,1,0), -Body.get_rotation().y)
	
	Skel.set_bone_custom_pose(LeftArmController_idx, pose)


###LOCAL SIGNAL COMMS###
func connect_local_signals():
#	owner.inventory.connect("equipped_items_changed", self, "_on_Player_equipped_items_changed")
	owner.get_node("AnimationPlayer").connect("animation_finished", self, "_on_animation_finished")
	owner.get_node("Camera_Rig").connect("camera_angle_changed", self, "_on_Camera_Rig_camera_angle_changed")
#	owner.get_node("Camera_Rig").connect("camera_raycast_collision_changed", self, "_on_camera_raycast_collision_changed")
	
	owner.get_node("State_Machines/State_Machine_Move/Timer_Aim").connect("timeout", self, "_on_Timer_Aim_timeout")
	owner.get_node("State_Machines/State_Machine_Action_L/Timer_Action_L").connect("timeout", self, "_on_Timer_Action_L_timeout")


func disconnect_local_signals():
#	owner.inventory.disconnect("equipped_items_changed", self, "_on_Player_equipped_items_changed")
	owner.get_node("AnimationPlayer").disconnect("animation_finished", self, "_on_animation_finished")
	owner.get_node("Camera_Rig").disconnect("camera_angle_changed", self, "_on_Camera_Rig_camera_angle_changed")
#	owner.get_node("Camera_Rig").disconnect("camera_raycast_collision_changed", self, "_on_camera_raycast_collision_changed")
	
	owner.get_node("State_Machines/State_Machine_Move/Timer_Aim").disconnect("timeout", self, "_on_Timer_Aim_timeout")
	owner.get_node("State_Machines/State_Machine_Action_L/Timer_Action_L").disconnect("timeout", self, "_on_Timer_Action_L_timeout")


func _on_Player_equipped_items_changed(equipped_items):
	State_Machine_Action_L.current_state.current_spell = equipped_items["Spell"]


func _on_Camera_Rig_camera_angle_changed(angles):
	camera_angles = angles


func _on_Timer_Aim_timeout():
	set_aiming(false)


func _on_Timer_Action_L_timeout():
	pass


###EXTERNAL SIGNAL COMMS###
func connect_external_signals():
	Global.get_camera_main().connect("camera_raycast_collision_changed", self, "_on_camera_raycast_collision_changed")
	GameManager.connect("transit_player_to_point", self, "_on_GameManager_transit_player_to_point")


func disconnect_external_signals():
	Global.get_camera_main().disconnect("camera_raycast_collision_changed", self, "_on_camera_raycast_collision_changed")
	GameManager.disconnect("transit_player_to_point", self, "_on_GameManager_transit_player_to_point")


func _on_camera_raycast_collision_changed(collision_point):
	camera_look_at_point = collision_point


func _on_GameManager_transit_player_to_point(override, position_node):
	if override:
		set_override_input(override) #Set override flag AFTER setting vars
	else:
		set_override_input(override)



