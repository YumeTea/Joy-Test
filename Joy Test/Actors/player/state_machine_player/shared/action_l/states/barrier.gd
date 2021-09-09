extends "res://Actors/player/state_machine_player/shared/action_l/action_l.gd"


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


#Acts as the _process method would
func update(delta):
	anchor_arm_l_transform()
	
	#Change arm anim blend values if they have changed
	Skel.set_bone_custom_pose(LeftArmController_idx, pose_blend_l)
	AnimTree.set("parameters/MotionActionLBlend/blend_amount", blend_motionactionl)
	
	#Wait until arm anim blending has been set back to 0 to exit barrier state
	if is_equal_approx(AnimTree.get("parameters/MotionActionLBlend/blend_amount"), 0.0):
		emit_signal("state_switch", "none")
		return
<<<<<<< HEAD
	
	#Handle arm transform if aiming
	if is_aiming:
		rotate_arm_l(camera_angles)
		rotate_barrier(camera_angles, true)
	else:
		rotate_arm_l(Body.get_rotation())
		rotate_barrier(Body.get_rotation(), true)
=======
>>>>>>> parent of ca028a4 (-added visual for default barrier)


func _on_animation_finished(anim_name):
	._on_animation_finished(anim_name)


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




