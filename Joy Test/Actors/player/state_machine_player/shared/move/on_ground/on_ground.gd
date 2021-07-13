extends "res://Actors/player/state_machine_player/shared/move/motion.gd"


#Initializes state, changes animation, etc
func enter():
	snap_vector = snap_vector_default
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
	
	if !owner.is_on_floor():
		if !is_aiming:
			emit_signal("state_switch", "fall")
		elif is_aiming:
			emit_signal("state_switch", "fall_aim")


func _on_animation_finished(_anim_name):
	return


func interp_walk_velocity(input_direction, current_velocity, delta):
	var temp_vel = Vector3(0,0,0)
	var new_speed : float
	var new_vel = Vector3(0,0,0)
	
	temp_vel.x = current_velocity.x
	temp_vel.z = current_velocity.z
	
	#Get portion of velocity that is pointing in input direction
	var dirdotvel = input_direction.normalized().dot(Vector2(temp_vel.x, temp_vel.z).normalized())
	dirdotvel = clamp(dirdotvel, 0, 1)
	temp_vel = input_direction.normalized() * (temp_vel.length() * dirdotvel)
	
	#Solve for current t and get next t
	var t : float
	var t_to_full = run_full_time / 2
	var x = 1.0/3.0
	t = pow((temp_vel.length() / run_speed_full), (1.0/x)) * run_full_time
	t += delta
	t = clamp(t, 0, run_full_time)
	
	#Solve for next velocity
	if t == run_full_time:
		new_speed = run_speed_full
	else:
		new_speed = (pow((t / run_full_time), x) * run_speed_full)
	
	#Set new velocity
	new_vel = Vector3(input_direction.x, 0, input_direction.y)
	new_vel *= new_speed
	
	
	
	#Add y velocity back in
	new_vel.y = current_velocity.y
	
	return new_vel


#func interp_walk_velocity(input_direction, current_velocity, delta):
#	var temp_vel = Vector3(0,0,0)
#	var new_speed : float
#	var new_vel = Vector3(0,0,0)
#
#	temp_vel.x = current_velocity.x
#	temp_vel.z = current_velocity.z
#
#	#Get portion of velocity that is pointing in input direction
#	var dirdotvel = input_direction.normalized().dot(Vector2(temp_vel.x, temp_vel.z).normalized())
#	dirdotvel = clamp(dirdotvel, 0, 1)
#	temp_vel = input_direction.normalized() * (temp_vel.length() * dirdotvel)
#
#	#Solve for current t and get next t
#	var t : float
#	var t_to_full = run_full_time / 2
#	var x = 1.0/3.0
#	t = pow((temp_vel.length() / run_speed_full), (1.0/x)) * run_full_time
#	t += delta
#	t = clamp(t, 0, run_full_time)
#
#	#Solve for next velocity
#	if t == run_full_time:
#		new_speed = run_speed_full
#	else:
#		new_speed = (pow((t / run_full_time), x) * run_speed_full)
#
#	#Set new velocity
#	new_vel = Vector3(input_direction.x, 0, input_direction.y)
#	new_vel *= new_speed
#
#
#	#Check new velocity
##	if new_vel.length() < speed_thresh_lower:
##		new_vel.x = 0
##		new_vel.z = 0
#
#	#Add y velocity back in
#	new_vel.y = current_velocity.y
#
#	return new_vel


#func interp_walk_velocity(input_direction, current_velocity, delta):
#	var temp_vel = Vector3(0,0,0)
#	var target_vel = Vector3(0,0,0)
#	var new_vel = Vector3(0,0,0)
#
#	temp_vel.x = current_velocity.x
#	temp_vel.z = current_velocity.z
#
#	target_vel.x = input_direction.x * run_speed_full
#	target_vel.z = input_direction.y * run_speed_full
#
#	#Get correct acceleration to use
#	var acceleration
#	if input_direction.length() > 0:
#		acceleration = walk_accel
#	else:
#		acceleration = walk_deaccel
#
#	new_vel = temp_vel.linear_interpolate(target_vel, acceleration * delta)
#
#	#Check new velocity
#	if new_vel.length() < speed_thresh_lower:
#		new_vel.x = 0
#		new_vel.z = 0
#
#	#Add y velocity back in
#	new_vel.y = current_velocity.y
#
#	return new_vel
