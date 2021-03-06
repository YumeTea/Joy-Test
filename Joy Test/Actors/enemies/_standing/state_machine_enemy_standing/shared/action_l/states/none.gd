extends "res://Actors/enemies/_standing/state_machine_enemy_standing/shared/action_l/action_l.gd"


var pose_blend : Transform
var blend_motionactionl : float


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_arm_l_occupied(false)
	
	anim_tree_play_anim("none_l", AnimStateMachineActionL)
	
	#Blend values to none state
	pose_blend = Skel.get_bone_custom_pose(LeftArmController_idx)
	
	blend_motionactionl = AnimTree.get("parameters/MotionActionLBlend/blend_amount")
	
	Tween_Player.interpolate_property(self, "pose_blend", pose_blend, Transform(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1), Vector3(0,0,0)), 0.25, 4)
	Tween_Player.interpolate_property(self, "blend_motionactionl", blend_motionactionl, 0.0, 0.25, 4)
	Tween_Player.start()
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	set_arm_l_occupied(true)
	
	AnimTree.set("parameters/MotionActionLBlend/blend_amount", 0.01)
	
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if arm_l_occupied:
		emit_signal("state_switch", "occupied_l")
		return
	
	Skel.set_bone_custom_pose(LeftArmController_idx, pose_blend)
	AnimTree.set("parameters/MotionActionLBlend/blend_amount", blend_motionactionl)
	
	.update(delta)


func _on_animation_finished(anim_name):
	._on_animation_finished(anim_name)


