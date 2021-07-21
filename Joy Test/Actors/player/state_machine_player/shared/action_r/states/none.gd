extends "res://Actors/player/state_machine_player/shared/action_r/action_r.gd"


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	AnimStateMachineActionR.start("none")
	
	if AnimStateMachineActionL.get_current_node() == "none":
		AnimTree.set("parameters/MotionActionBlend/blend_amount", 0.0)
		
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	AnimTree.set("parameters/MotionActionBlend/blend_amount", 1.0)
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_pressed("aim_r"):
		set_aiming(true)
	
	if Input.is_action_just_pressed("attack_right"):
		if !is_aiming:
			emit_signal("state_switch", "jab")
		elif is_aiming:
			emit_signal("state_switch", "jab_aim")
	
	.handle_input(event)


#Acts as the _process method would
func update(_delta):
	return


func _on_animation_finished(anim_name):
	if anim_name == "jab":
		AnimStateMachineActionR.start("none")
	
	._on_animation_finished(anim_name)

