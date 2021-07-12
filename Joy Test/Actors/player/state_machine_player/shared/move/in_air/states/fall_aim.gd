extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"



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
		emit_signal("state_switch", "fall")
	
	rotate_to_direction(null)
	
	velocity = calc_aerial_velocity(velocity, delta)
	
	.update(delta)


func _on_animation_finished(_anim_name):
	return


func rotate_to_direction(direction): #Direction should be normalized
	var angle = camera_angles.y
	
	var rot_final = Body.get_rotation()
	rot_final.y = angle
	
	Body.set_rotation(rot_final)

