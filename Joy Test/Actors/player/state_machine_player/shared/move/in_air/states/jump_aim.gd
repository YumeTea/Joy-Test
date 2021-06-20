extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"


#Jump Variables
var jump_velocity = 28


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_aiming(true)
	has_jumped = false
	velocity = add_jump_velocity(velocity)
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	set_aiming(false)
	.exit()


#Creates output based on the input event passed in
func handle_input(_event):
	if Input.is_action_just_released("aim_r"):
		if Timer_Move.is_stopped() and is_aiming:
			Timer_Move.start(1)
	elif Input.is_action_just_pressed("aim_r"):
		if !Timer_Move.is_stopped():
			Timer_Move.stop()


#Acts as the _process method would
func update(delta):
	if is_aiming == false:
		emit_signal("state_switch", "fall")
	
	rotate_to_direction(null)
	
	.update(delta)


func _on_animation_finished(_anim_name):
	return


func calc_air_speed(velocity):
	pass


#Call this function in future animation
func add_jump_velocity(velocity):
	velocity.y = jump_velocity
	snap_vector = Vector3(0,0,0) #disable snap vector so player can leave floor
	has_jumped = true
	
	return velocity


func rotate_to_direction(direction): #Direction should be normalized
	var angle = rad2deg(camera_angles.y)
	
	var rot_final = Body.get_rotation_degrees()
	rot_final.y = angle
	
	Body.set_rotation_degrees(rot_final)

