extends "res://Actors/player/state_machine_player/shared/action_l/action_l.gd"


var pose_blend : Transform
var blend_motionactionl : float


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	if !AnimStateMachineActionL.is_playing():
		AnimStateMachineActionL.start("none_l")
	else:
		AnimStateMachineActionL.travel("none_l")
	
	#Blend values to none state
	pose_blend = Skel.get_bone_custom_pose(LeftArmController_idx)
	
	blend_motionactionl = AnimTree.get("parameters/MotionActionLBlend/blend_amount")
	
	Tween_Player.interpolate_property(self, "pose_blend", pose_blend, Transform(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1), Vector3(0,0,0)), 0.25, 4)
	Tween_Player.interpolate_property(self, "blend_motionactionl", blend_motionactionl, 0.0, 0.25, 4)
	Tween_Player.start()
	
	AnimTree.set("parameters/MotionActionLBlend/blend_amount", 0.0)
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	AnimTree.set("parameters/MotionActionLBlend/blend_amount", 0.01)
	
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("attack_left"):
		#Branch to correct state based on equipped spell type
		match current_spell.spell_type:
			"projectile":
				if !is_aiming:
					emit_signal("state_switch", "cast")
				elif is_aiming:
					emit_signal("state_switch", "cast_aim")
			"barrier":
				if !is_aiming:
					emit_signal("state_switch", "barrier")
				elif is_aiming:
					emit_signal("state_switch", "barrier_aim")
			"held_affect":
				pass
	
	if Input.is_action_just_pressed("attack_left_alt"):
		if current_spell.alt_cast == true:
			#Branch to correct state based on equipped spell type
			match current_spell.spell_type:
				"projectile":
					pass
				"barrier":
					emit_signal("state_switch", "barrier_ground")
				"held_affect":
					pass
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	Skel.set_bone_custom_pose(LeftArmController_idx, pose_blend)
	AnimTree.set("parameters/MotionActionLBlend/blend_amount", blend_motionactionl)
	
	.update(delta)


func _on_animation_finished(anim_name):
	._on_animation_finished(anim_name)

