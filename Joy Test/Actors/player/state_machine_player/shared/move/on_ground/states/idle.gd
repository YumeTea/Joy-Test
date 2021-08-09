extends "res://Actors/player/state_machine_player/shared/move/on_ground/on_ground.gd"

#Idle variables
var deaccel = 8

var ground_speed_thresh_lower = 0.1


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_fasten_to_floor(true)
	
	#Animation must be started on player first being in scene
	anim_tree_play_anim("idle", AnimStateMachineMotion)
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if is_b_sliding:
		emit_signal("state_switch", "barrier_slide")
		return
	
	if is_aiming:
		rotate_to_direction(Vector2(0,-1).rotated(-camera_angles.y))
	
	#Remove fasten v from total v
	velocity -= velocity_fasten
	
	#Calc idle velocity
	velocity = calc_idle_velocity(velocity, delta)
	
	.update(delta)
	
	if get_joystick_input_l().length() > 0.0: #Should state be switch at the beginning or end?
		emit_signal("state_switch", "walk")
		return
	###SIMULATED BUFFERING###
	if Input.is_action_pressed("jump"):
		emit_signal("state_switch", "jump")
		return
	#######################################


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

