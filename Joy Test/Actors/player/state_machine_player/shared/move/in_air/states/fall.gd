extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"



func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	#Zero out fasten velocity in states where player is not fastened
	velocity_fasten = Vector3(0,0,0)
	
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
	if grab_data["grab_point"] != null and can_ledge_grab and !arm_r_occupied:
		emit_signal("state_switch", "ledge_hang")
		return
	
	if is_aiming:
		rotate_to_direction(Vector2(0,-1).rotated(-camera_angles.y))
	
	velocity = calc_aerial_velocity(velocity, delta)
	
	.update(delta)
	
	if owner.is_on_wall() and !can_wall_jump:
		check_can_wall_jump()


func _on_animation_finished(_anim_name):
	return




