extends "res://Actors/player/state_machine_player/shared/move/on_ground/on_ground.gd"


#Idle variables
var deaccel = 8

var ground_speed_thresh_lower = 0.1


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_aiming(true)
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	set_aiming(false)
	.exit()

#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_released("aim_r"):
		if Timer_Move.is_stopped() and is_aiming:
			Timer_Move.start(1)
	elif Input.is_action_just_pressed("aim_r"):
		if !Timer_Move.is_stopped():
			Timer_Move.stop()


#Acts as the _process method would
func update(delta):
	if is_aiming == false:
		emit_signal("state_switch", "idle")
	
	rotate_to_direction(null)
	
	velocity = calc_idle_velocity(velocity, delta)
	
	.update(delta)
	
	if get_joystick_input_l().length() > 0.0: #Should state be switch at the beginning or end?
		emit_signal("state_switch", "walk_aim")
		return
	###SIMULATED BUFFERING###
	if Input.is_action_pressed("jump"):
		emit_signal("state_switch", "jump_aim")
		return


func _on_animation_finished(_anim_name):
	return


func calc_idle_velocity(current_velocity, delta):
	var temp_vel = Vector3(0,0,0)
	var target_vel = Vector3(0,0,0)
	var new_vel = Vector3(0,0,0)
	
	temp_vel.x = current_velocity.x
	temp_vel.z = current_velocity.z
	
	target_vel.x = 0
	target_vel.z = 0
	
	new_vel = temp_vel.linear_interpolate(target_vel, deaccel * delta)
	
	
	return new_vel


func rotate_to_direction(direction): #Direction should be normalized
	var angle = rad2deg(camera_angles.y)
	
	var rot_final = Body.get_rotation_degrees()
	rot_final.y = angle
	
	Body.set_rotation_degrees(rot_final)


