extends "res://Actors/player/state_machine_player/shared/move/motion.gd"


#In Air bools
var has_jumped = true


#Initializes state, changes animation, etc
func enter():
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	.update(delta)
	
	if owner.is_on_floor() and has_jumped: #check has_jumped to allow jump squat to play out
		emit_signal("state_switch", "idle")
		return


func _on_animation_finished(_anim_name):
	return


func calc_aerial_velocity(current_velocity, delta):
	var input : Vector2
	var input_direction : Vector2
	var velocity : Vector3
	
	input = get_joystick_input_l()
	
	input_direction = input.rotated(-camera_angles.y)
	
	#Rotate player
#	rotate_to_direction(input_direction)
	
	#Handling of input direction to prevent unintended slowing at higher speeds and velocity directed input
	var velocity_horizontal = Vector2(current_velocity.x, current_velocity.z).length()
	var dirdotvel = input_direction.normalized().dot(Vector2(current_velocity.x, current_velocity.z).normalized())
	if velocity_horizontal > air_speed_full and dirdotvel >= 0:
		velocity = steer_aerial_velocity(input_direction, current_velocity, delta)
	else:
		velocity = interp_aerial_velocity(input_direction, current_velocity, delta)
	
	return velocity


func steer_aerial_velocity(input_direction, current_velocity, delta):
	var temp_vel = Vector3(0,0,0)
	var new_vel = Vector3(0,0,0)
	
	var vel1 = Vector2(current_velocity.x, current_velocity.z)
	var vel2 = input_direction * air_accel / 4
	
	temp_vel = (vel1 + vel2).normalized() * vel1.length()
	
	#Set new_vel
	new_vel.x = temp_vel.x
	new_vel.z = temp_vel.y
	new_vel.y = current_velocity.y
	
	return new_vel


func interp_aerial_velocity(input_direction, current_velocity, delta):
	var temp_vel = Vector3(0,0,0)
	var target_vel = Vector3(0,0,0)
	var new_vel = Vector3(0,0,0)
	
	temp_vel.x = current_velocity.x
	temp_vel.z = current_velocity.z
	
	target_vel.x = input_direction.x * air_speed_full
	target_vel.z = input_direction.y * air_speed_full
	
	#Get correct acceleration to use
	var acceleration
	if input_direction.length() > 0:
		acceleration = air_accel
	else:
		acceleration = air_deaccel
	
	new_vel = temp_vel.linear_interpolate(target_vel, acceleration * delta)
	
	#Check new velocity
	if new_vel.length() < speed_thresh_lower:
		new_vel.x = 0
		new_vel.z = 0
	
	#Add y velocity back in
	new_vel.y = current_velocity.y
	
	return new_vel


###FLAG FUNCTIONS
func set_jumped(value):
	has_jumped = value














