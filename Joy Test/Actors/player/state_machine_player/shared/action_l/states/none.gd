extends "res://Actors/player/state_machine_player/shared/action_l/action_l.gd"


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_arm_l_occupied(false)
	
	anim_tree_play_anim("none_l", AnimStateMachineActionL)
	
	#Blend values to none state
	pose_blend_l = Skel.get_bone_custom_pose(LeftArmController_idx)
	
	blend_motionactionl = AnimTree.get("parameters/MotionActionLBlend/blend_amount")
	
	Tween_Player.interpolate_property(self, "pose_blend_l", pose_blend_l, Transform(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1), Vector3(0,0,0)), 0.25, 4)
	Tween_Player.interpolate_property(self, "blend_motionactionl", blend_motionactionl, 0.0, 0.25, 4)
	Tween_Player.start()
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	set_arm_l_occupied(true)
	
	Tween_Player.stop(self, "pose_blend_l")
	Tween_Player.stop(self, "blend_motionactionl")
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
	
	Skel.set_bone_custom_pose(LeftArmController_idx, pose_blend_l)
	AnimTree.set("parameters/MotionActionLBlend/blend_amount", blend_motionactionl)
	
	.update(delta)
	
	#INPUT HANDLING
	handle_held_input()


func _on_animation_finished(anim_name):
	._on_animation_finished(anim_name)


func handle_held_input():
	if Input.is_action_pressed("attack_left"):
		#Branch to correct state based on equipped spell type
		match current_spell.spell_type:
			"projectile":
				emit_signal("state_switch", "cast")
				return
			"barrier":
				emit_signal("state_switch", "barrier")
				return
			"held_affect":
				pass
	
	if Input.is_action_pressed("attack_left_alt"):
		if current_spell.alt_cast == true:
			#Branch to correct state based on equipped spell type
			match current_spell.spell_type:
				"projectile":
					pass
				"barrier":
					emit_signal("state_switch", "barrier_ground")
					return
				"held_affect":
					pass


