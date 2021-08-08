extends "res://Actors/player/state_machine_player/shared/move/on_ground/on_ground.gd"


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_stop_on_slope(false)
	set_fasten_to_floor(false)
	
	anim_tree_play_anim("barrier_slide", AnimStateMachineMotion)
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	set_stop_on_slope(true)
	set_fasten_to_floor(true)
	
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if !is_b_sliding:
		emit_signal("state_switch", "walk")
		return
	
	.update(delta)
	
	###SIMULATED BUFFERING###
	if Input.is_action_pressed("jump"):
		emit_signal("state_switch", "jump")
		return
	#####################################


func _on_animation_finished(anim_name):
	._on_animation_finished(anim_name)
