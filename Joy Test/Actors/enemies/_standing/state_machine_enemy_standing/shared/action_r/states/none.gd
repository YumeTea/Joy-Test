extends "res://Actors/enemies/_standing/state_machine_enemy_standing/shared/action_r/action_r.gd"


var blend_motionactionr : float


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_arm_r_occupied(false)
	
	reset_custom_pose_arm_r()
	
	anim_tree_play_anim("none", AnimStateMachineActionR)
	
	#Blend values to none state
	blend_motionactionr = AnimTree.get("parameters/MotionActionRBlend/blend_amount")
	
	Tween_Player.interpolate_property(self, "blend_motionactionr", blend_motionactionr, 0.0, 0.25, 4)
	Tween_Player.start()
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	set_arm_r_occupied(true)
	
	AnimTree.set("parameters/MotionActionRBlend/blend_amount", 0.99)
	
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if arm_r_occupied:
		emit_signal("state_switch", "occupied_r")
		return
	
	AnimTree.set("parameters/MotionActionRBlend/blend_amount", blend_motionactionr)
	
	.update(delta)


func _on_animation_finished(anim_name):
	._on_animation_finished(anim_name)

