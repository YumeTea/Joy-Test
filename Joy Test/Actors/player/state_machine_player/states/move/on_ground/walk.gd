extends "res://Actors/player/state_machine_player/states/move/on_ground/on_ground.gd"

#Walk Variables
var walk_speed_thresh_lower = 0.1


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	connect_player_signals()


#Cleans up state, reinitializes values like timers
func exit():
	disconnect_player_signals()


#Creates output based on the input event passed in
func handle_input(event):
	return


#Acts as the _process method would
func update(delta):
	velocity = move_player(velocity, delta)
	
	.update(delta)
	
	if velocity.length() < walk_speed_thresh_lower and get_joystick_input_l().length() == 0.0:
		emit_signal("state_switch", "idle")


func _on_animation_finished(_anim_name):
	return


###WALK FUNCTIONS###
func move_player(current_velocity, delta):
	var input : Vector2
	var input_direction : Vector2
	var velocity : Vector3
	
	input = get_joystick_input_l()
	
	#Get direction
	input_direction = input.normalized().rotated(-camera_angle.y)
	
	velocity = calc_velocity(input_direction, current_velocity, delta)
	
	if input.length() > 0:
		rotate_to_direction(input_direction)
	
	return(velocity)


func calc_velocity(input_direction, current_velocity, delta):
	#Velocity
	velocity.x = input_direction.x * speed_full
	velocity.z = input_direction.y * speed_full
	
	velocity.y = current_velocity.y + (gravity * weight * delta)
	
	return velocity


func rotate_to_direction(direction): #Direction should be normalized
	var angle = rad2deg(Vector2(0, 1).angle_to(-direction))
	
	var rot_final = Body.get_rotation_degrees()
	rot_final.y = -angle
	
	Body.set_rotation_degrees(rot_final)



