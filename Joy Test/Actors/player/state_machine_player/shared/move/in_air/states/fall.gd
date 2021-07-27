extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"



func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	anim_tree_play_anim("fall", AnimStateMachineMotion)
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if is_aiming:
		rotate_to_direction(Vector2(0,-1).rotated(-camera_angles.y))
	
	velocity = calc_aerial_velocity(velocity, delta)
	
	.update(delta)


func _on_animation_finished(_anim_name):
	return




