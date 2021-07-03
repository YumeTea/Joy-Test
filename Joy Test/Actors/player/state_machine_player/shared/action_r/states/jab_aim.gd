extends "res://Actors/player/state_machine_player/shared/action_r/action_r.gd"


#Jab Variables
var jab_strength = 56

var arm_transform_default : Transform
var aim_interp_radius_inner = 7
var aim_interp_radius_outer = 12

#Pose Variables
onready var RightArmController_idx = Skel.find_bone("RightArmController")

#Node Storage
onready var RightArmController = owner.get_node("Body/Armature/Skeleton/RightArmController")
var Needle_Arm_Raycast : Node


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_hit_active(false) #is also set by animation
	set_hit(false)
	
	Needle_Arm_Raycast = owner.get_node("Body/Armature/Skeleton/RightArmController/RayCast")
	Needle_Arm_Raycast.connect("raycast_collided", self, "_on_jab_collision")
	
	aim_arm_transform(camera_look_at_point)
	
	AnimStateMachineActionR.start("jab_test")
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	reset_arm_rotation()
	
	Needle_Arm_Raycast.disconnect("raycast_collided", self, "_on_jab_collision")
	
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(_delta):
	return


func _on_animation_finished(anim_name):
	if anim_name == "jab_test":
		AnimStateMachineActionR.start("none")
#		reset_arm_rotation()
		emit_signal("state_switch", "none")


#Must use rest pose because anim pose transforms happen after this runs
func aim_arm_transform(look_at_point):
	var jab_point : Vector3
	var look_vec : Vector3
	var interp_point : Vector3
	var interp_factor : float

	var controller_pose_custom : Transform
	var controller_pose : Transform
	var pose_new : Transform

	#Set arm custom pose back to default
	reset_arm_rotation()

	jab_point = look_at_point #This point is global
	#Get look direction vector and center it at jab controller point
	look_vec = Vector3(0,0,-1).rotated(Vector3(1,0,0), camera_angles.x)
	interp_point = RightArmController.to_global(look_vec)
	
	#Interpolation factor for look at point
	var radius = (jab_point - Body.get_global_transform().origin).length()
	
	if radius > aim_interp_radius_outer:
		interp_factor = 0
	elif radius < aim_interp_radius_inner:
		interp_factor = 1
	else:
		interp_factor = (aim_interp_radius_outer - radius) / (aim_interp_radius_outer - aim_interp_radius_inner)
	
	#Interpolation
	jab_point = jab_point.linear_interpolate(interp_point, interp_factor)
	
	
	#Get current pose transform
	controller_pose_custom = Skel.get_bone_custom_pose(RightArmController_idx)
	controller_pose = Skel.get_bone_pose(RightArmController_idx)
	
	
	jab_point = RightArmController.to_local(jab_point)
	#Rotate look at point by opposite of controller bone's pose
	var rot = controller_pose.basis.get_rotation_quat().get_euler()
	jab_point = jab_point.rotated(Vector3(1,0,0), rot.x)
	jab_point = jab_point.rotated(Vector3(0,1,0), rot.y)
	jab_point = jab_point.rotated(Vector3(0,0,1), rot.z)
	
	#Set controller pose looking at look at point in bone's local space
	pose_new = controller_pose_custom.looking_at(jab_point, Vector3(0,1,0))
	
	#Rotate controller default custom pose by difference in new and old controller pose
	rot = pose_new.basis.get_rotation_quat().get_euler() - controller_pose.basis.get_rotation_quat().get_euler()
	pose_new = controller_pose_custom
	pose_new = pose_new.rotated(Vector3(1,0,0), rot.x)
	pose_new = pose_new.rotated(Vector3(0,1,0), rot.y)
	pose_new = pose_new.rotated(Vector3(0,0,1), rot.z)
	
	#Apply pose
	Skel.set_bone_custom_pose(RightArmController_idx, pose_new)
	
	
	#Debug
#	print(interp_factor)
#	Debug_Point.global_transform.origin = jab_point


func reset_arm_rotation():
	var transform : Transform
	
	transform.origin = Vector3(0,0,0)
	transform.basis.x = Vector3(1,0,0)
	transform.basis.y = Vector3(0,1,0)
	transform.basis.z = Vector3(0,0,1)
	
	Skel.set_bone_custom_pose(RightArmController_idx, transform)


func _on_jab_collision(collision):
	if hit_active and !has_hit:
		var collision_material = collision["col_material"]
		
		if collision_material in GlobalValues.collision_materials_solid:
			var velocity = add_recoil_velocity(collision)
			
			collision["recoil_vel"] = velocity
			
			emit_signal("jab_collision", collision)
		elif collision_material in GlobalValues.collision_materials_soft:
			anim_pause_position = AnimStateMachineActionR.get_current_play_position()
			AnimStateMachineActionR.stop()
			
			attached_obj = collision["collider"]
			stick_point = attached_obj.to_local(collision["col_point"])
			
			emit_signal("jab_collision", collision)
			emit_signal("state_switch", "jab_stick")
	
	set_hit_active(false)
	set_hit(true)


func add_recoil_velocity(collision):
	var recoil_velocity = Vector3(0,0,0)
	var recoil_vector = collision["col_normal"]
	var collision_type = collision["col_type"]
	
	if collision_type == "strong":
		recoil_velocity += recoil_vector * jab_strength
	elif collision_type == "weak":
		recoil_velocity += recoil_vector * jab_strength #should be weaker in the future
	else:
		print("invalid collision type sent to jab state")
		assert(1 == 2)
	
	return recoil_velocity


