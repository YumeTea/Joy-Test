extends "res://Actors/player/state_machine_player/shared/action_l/action_l.gd"


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	start_barrier_anim()
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)
	
	if Input.is_action_just_released("attack_left"):
		emit_signal("state_switch", "none")
		return
	elif Input.is_action_just_pressed("aim_r") or is_aiming:
		emit_signal("state_switch", "barrier_aim")
		return


#Acts as the _process method would
func update(delta):
	anchor_arm_l_transform()


func _on_animation_finished(anim_name):
	._on_animation_finished(anim_name)


###ANIMATION FUNCTIONS###
func start_barrier_anim():
	AnimTree.set("parameters/MotionActionLBlend/blend_amount", 0.99)
	anim_tree_play_anim("barrier_up", AnimStateMachineActionL)

