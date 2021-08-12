extends "res://Actors/player/state_machine_player/shared/move/motion.gd"


#Wall Jump Values
#var wall_angle_variance = deg2rad(18)
var wall_angle_variance = deg2rad(75)

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
	if Input.is_action_just_pressed("jump"):
		if can_wall_jump and !arm_l_occupied and !arm_r_occupied:
			emit_signal("state_switch", "wall_jump")
			return
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if fasten_to_ledge:
		#Calc fasten velocity
		velocity_fasten = calc_fasten_velocity(delta)
		
		#Fasten player
		velocity_fasten = owner.move_and_slide_with_snap(velocity_fasten, snap_vector, Vector3(0, 1, 0), stop_on_slope, 4, deg2rad(50))
		
		print(velocity_fasten)
		
		#Check if player collided, if so let go
		for col_idx in owner.get_slide_count():
			var collision = owner.get_slide_collision(col_idx)
			if collision.collider != hang_obj:
				let_go_ledge()
				emit_signal("state_switch", "fall")
				return
		
	
	.update(delta)
	
	#Get new ledge grab point if ledge hanging
	if fasten_to_ledge:
		hang_point = hang_obj.to_local(Ledge_Grab_Position.get_global_transform().origin)
	
	if owner.is_on_floor() and has_jumped: #check has_jumped to allow jump squat to play out
		snap_vector = snap_vector_default
		if is_b_sliding:
			emit_signal("state_switch", "barrier_slide")
			return
		else:
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
	if velocity_horizontal > air_speed_full and dirdotvel >= -0.5: #steer if faster than natural air speed and input is outside of brake cone
		velocity = steer_aerial_velocity(input_direction, current_velocity, delta)
	else:
		velocity = interp_aerial_velocity(input_direction, current_velocity, delta)
	
	return velocity



func steer_aerial_velocity(input_direction, current_velocity, delta):
	var temp_vel = Vector3(0,0,0)
	var new_vel = Vector3(0,0,0)
	
	var vel1 = Vector2(current_velocity.x, current_velocity.z) #current horizontal v
	var vel2 = input_direction * air_accel / 8
	
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


###LEDGE HANG FUNCTIONS###
#Calculates velocity to grab point if hang_obj moved, also rotates velocity if hang_obj moved
func calc_fasten_velocity(delta):
	var new_vel : Vector3
	
	if hang_obj != null:
		#Calc fasten vel
		new_vel = (hang_obj.to_global(hang_point) - Ledge_Grab_Position.get_global_transform().origin) / delta
		
		#Rotate player
		var dir = hang_obj.to_global(hang_dir) - hang_obj.get_global_transform().origin
		var dir_prev = hang_dir_prev
		
		var angle = Vector2(dir.x, dir.z).angle_to(Vector2(dir_prev.x, dir_prev.z))
		
		Body.rotate_y(angle)
		
		#Rotate velocity
		velocity = velocity.rotated(Vector3(0,1,0), angle)
		
		#Set new prev facing dir for next frame
		hang_dir_prev = dir
	else:
		new_vel = Vector3(0,0,0)
	
	return new_vel


#Essentially same as snap_to_ledge
func rotate_about_grab_point(grab_point, direction):
	#Rotate player
	rotate_to_direction(direction)
	
	#Rotate hang_dir and hang_dir_prev if necessary
	var grab_dir = hang_obj.to_global(hang_dir) - hang_obj.get_global_transform().origin
	var angle = Vector2(grab_dir.x, grab_dir.z).angle_to(Vector2(direction.x, direction.y))
	
	hang_dir = hang_dir.rotated(Vector3(0,1,0), angle)
	hang_dir_prev = hang_dir_prev.rotated(Vector3(0,1,0), angle)
	
	#Translate player to grab_point
	var translate = grab_point - Ledge_Grab_Position.get_global_transform().origin
	
	owner.translate(translate)
	
	Ledge_Grab_Position.force_update_transform()


func let_go_ledge():
	velocity_fasten = Vector3(0,0,0)
	set_fasten_to_ledge(false)
	set_can_ledge_grab(false)
	set_arm_r_occupied(false)
	Timer_Ledge_Grab.start()
	emit_signal("on_ledge", false)


###WALL JUMP FUNCTIONS###
func check_can_wall_jump():
	for slide_idx in owner.get_slide_count():
		var collision = owner.get_slide_collision(slide_idx)
		
		var wall_angle : float
		
		wall_angle = Vector3(0,1,0).angle_to(collision.normal)
		#Check if current collision is with a wall jumpable wall
		if wall_angle >= (deg2rad(90) - wall_angle_variance) and wall_angle <= (deg2rad(90) + wall_angle_variance):
			var vdotwall : float
		
			vdotwall = collision.travel.normalized().dot(collision.normal)
			
			#Check if wall jump is valid based on velocity and wall normal
			if vdotwall <= -((deg2rad(90) - wall_angle_variance) / deg2rad(90)):
				set_can_wall_jump(true)
				set_wall_col(collision)
		else:
			continue


###FLAG FUNCTIONS
func set_jumped(value):
	has_jumped = value
	











