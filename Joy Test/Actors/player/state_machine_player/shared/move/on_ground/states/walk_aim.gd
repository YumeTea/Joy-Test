extends "res://Actors/player/state_machine_player/shared/move/on_ground/on_ground.gd"


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_aiming(true)
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if is_aiming == false:
		emit_signal("state_switch", "walk")
	
	velocity = calc_walk_velocity(velocity, delta)
	
	.update(delta)
	
	if velocity.length() < speed_thresh_lower and get_joystick_input_l().length() == 0.0:
		emit_signal("state_switch", "idle_aim")
		return
	
	###SIMULATED BUFFERING###
	if Input.is_action_pressed("jump"):
		emit_signal("state_switch", "jump_aim")
		return


func _on_animation_finished(_anim_name):
	return


###WALK FUNCTIONS###
#Try to keep this function generalized to work for any walk state
#Could be moved to main motion script if left generalized
func calc_walk_velocity(current_velocity, delta):
	var input : Vector2
	var input_direction : Vector2
	var velocity : Vector3
	
	#Get input
	input = get_joystick_input_l()
	
	#Get direction
	input_direction = input.rotated(-camera_angles.y)
	
	#Rotate player
	rotate_to_direction(Vector2(0,-1).rotated(-camera_angles.y))
	
	#Get next player velocity
	velocity = interp_walk_velocity(input_direction, current_velocity, delta)
	
	return velocity






