extends "res://Actors/player/state_machine_player/shared/action_l/action_l.gd"


var barrier_object
var barrier_instance


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	barrier_object = load(current_spell.object_scene)
	
	start_barrier_anim()
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	barrier_instance.queue_free()
	
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)
	
	if Input.is_action_just_released("attack_left"):
		end_barrier_anim()
#	elif Input.is_action_just_pressed("aim_r") or is_aiming:
#		emit_signal("state_switch", "barrier_aim")
#		return


#Acts as the _process method would
func update(delta):
	anchor_arm_l_transform()
	
	#Change arm anim blend values if they have changed
#	Skel.set_bone_custom_pose(LeftArmController_idx, pose_blend_l)
	AnimTree.set("parameters/MotionActionLBlend/blend_amount", blend_motionactionl)
	
	#Wait until arm anim blending has been set back to 0 to exit barrier state
	if is_equal_approx(AnimTree.get("parameters/MotionActionLBlend/blend_amount"), 0.0):
		emit_signal("state_switch", "none")
		return
	
	#Handle arm transform if aiming
	if is_aiming:
		rotate_arm_l()
		rotate_barrier()
	else:
		reset_custom_pose_rotation_arm_l()
		reset_barrier_rotation()


func _on_animation_finished(anim_name):
	._on_animation_finished(anim_name)


func rotate_arm_l():
	var look_at_point : Vector3
	var pose : Transform
	
	#Orient look at point
	look_at_point = Vector3(0,0,-1).rotated(Vector3(1,0,0), camera_angles.x)
	look_at_point = look_at_point.rotated(Vector3(0,1,0), camera_angles.y - Body.get_rotation().y)
	
	#Create custom pose
	pose.origin = Vector3(0,0,0)
	pose.basis = Basis(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1))
	
	pose = pose.looking_at(look_at_point, Vector3(0,1,0))
	
	#Put controller bone origin back where it was
	pose.origin = Skel.get_bone_custom_pose(LeftArmController_idx).origin
	
	#Apply custom pose
	Skel.set_bone_custom_pose(LeftArmController_idx, pose)


func rotate_barrier():
	Barrier_Pivot.rotation.x = camera_angles.x
	Barrier_Pivot.rotation.y = camera_angles.y - Body.get_rotation().y


func reset_barrier_rotation():
	Barrier_Pivot.set_rotation(Vector3(0,0,0))


###ANIMATION FUNCTIONS###
func start_barrier_anim():
	#Add barrier object to player
	barrier_instance = barrier_object.instance()
	Barrier_Origin.add_child(barrier_instance)
	
	#Set arm l blend amount directly and set local blend_amount variable (because not tweening)
	AnimTree.set("parameters/MotionActionLBlend/blend_amount", 0.99)
	blend_motionactionl = 0.99
	anim_tree_play_anim("barrier_up", AnimStateMachineActionL)


func end_barrier_anim():
	anim_tree_play_anim("none_l", AnimStateMachineActionL)
	
	#Blend values to none state
	pose_blend_l = Skel.get_bone_custom_pose(LeftArmController_idx)
	
	blend_motionactionl = AnimTree.get("parameters/MotionActionLBlend/blend_amount")
	
	Tween_Player.interpolate_property(self, "pose_blend_l", pose_blend_l, Transform(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1), Vector3(0,0,0)), 0.25, 4)
	Tween_Player.interpolate_property(self, "blend_motionactionl", blend_motionactionl, 0.0, 0.25, 4)
	Tween_Player.start()




