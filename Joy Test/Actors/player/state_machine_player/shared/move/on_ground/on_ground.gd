extends "res://Actors/player/state_machine_player/shared/move/motion.gd"


var turn_radius = deg2rad(12)


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
	if fasten_to_floor:
		#Calc fasten velocity
		velocity_fasten = calc_fasten_velocity(delta)
		
		#Fasten player
		velocity_fasten = owner.move_and_slide_with_snap(velocity_fasten, snap_vector, Vector3(0, 1, 0), stop_on_slope, 4, deg2rad(50))
	
	#Run upper level velocity calcs
	.update(delta)
	
	if !owner.is_on_floor():
		emit_signal("state_switch", "fall")
		return


func _on_animation_finished(_anim_name):
	return


func interp_walk_velocity(input_direction, current_velocity, delta):
	var temp_vel = Vector3(0,0,0)
	var target_vel = Vector3(0,0,0)
	var new_vel = Vector3(0,0,0)
	
	temp_vel.x = current_velocity.x
	temp_vel.z = current_velocity.z
	
	
	#Get portion of velocity that is pointing in input direction
	var dirdotvel = input_direction.normalized().dot(Vector2(temp_vel.x, temp_vel.z).normalized())
	dirdotvel = clamp(dirdotvel, 0, 1)
	if dirdotvel >= 0.995:
		target_vel = input_direction.normalized() * (temp_vel.length())
	else:
		target_vel = input_direction.normalized() * (temp_vel.length() * dirdotvel)
	
	#Solve for current t
	var t : float
	var t_to_full = run_full_time / 2
	var x = 1.0/3.0
	t = pow((target_vel.length() / run_speed_full), (1.0/x)) * run_full_time
	t = clamp(t, 0, run_full_time)
	
	#Solve for target velocity
	var target_t : float
	var target_speed : float
	target_t = clamp(t + delta, 0, run_full_time)
	target_speed = (pow((target_t / run_full_time), x) * run_speed_full)
	
	target_vel = Vector3(input_direction.x, 0, input_direction.y)
	target_vel *= target_speed
	
	#Step current velocity to target velocity
	var step_vel : Vector3
	var step_mag : float
	
	if temp_vel.length() <= target_vel.length() or is_equal_approx(temp_vel.length(), target_vel.length()):
		step_vel = (target_vel - temp_vel)
	else:
		step_mag = min(2.4, (target_vel - temp_vel).length())
		
		step_vel = (target_vel - temp_vel).normalized() * step_mag
	
	#Set new velocity
	new_vel = temp_vel + step_vel
	
	#Add y velocity back in
	new_vel.y = current_velocity.y
	
	return new_vel


#Calcs fasten velocity and rotates player if necessary
func calc_fasten_velocity(delta):
	var new_vel : Vector3
	
	if attached_floor != null:
		#Calc fasten vel
		new_vel = (attached_floor.to_global(attached_pos) - owner.get_global_transform().origin) / delta
		new_vel.y += 0.000015 / delta
		
		#Rotate player
		var dir = attached_floor.to_global(attached_dir) - attached_floor.get_global_transform().origin
		var dir_prev = attached_dir_prev
		
		var angle = Vector2(dir.x, dir.z).angle_to(Vector2(dir_prev.x, dir_prev.z))
		
		Body.rotate_y(angle)
		
		#Set new prev facing dir for next frame
		attached_dir_prev = dir
	else:
		new_vel = Vector3(0,0,0)
	
	return new_vel


#func set_fasten_vectors():
#	attached_pos = null
#	attached_dir = null
#	attached_floor = null
#
#	RayCast_Floor.force_raycast_update()
#
#	if RayCast_Floor.is_colliding() and owner.is_on_floor():
#		var collision : KinematicCollision
#
#		for col_idx in owner.get_slide_count():
#			collision = owner.get_slide_collision(col_idx)
#
#			if collision.collider == RayCast_Floor.get_collider():
#				attached_floor = collision.collider
#				attached_pos = attached_floor.to_local(RayCast_Floor.get_collision_point())
#				attached_dir = attached_floor.to_local(get_facing_direction_horizontal(Body))
#				return


#Original walk velocity calc
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
