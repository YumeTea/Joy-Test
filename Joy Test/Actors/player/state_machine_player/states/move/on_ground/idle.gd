extends "res://Actors/player/state_machine_player/states/move/on_ground/on_ground.gd"


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
func handle_input(_event):
	return


#Acts as the _process method would
func update(delta):
	velocity = calc_velocity(velocity, delta)
	.update(delta)
	
	if get_joystick_input_l().length() > 0.0: #Should state be switch at the beginning or end?
		emit_signal("state_switch", "walk")


func _on_animation_finished(_anim_name):
	return


func calc_velocity(current_velocity, delta):
	velocity.y = current_velocity.y + (gravity * weight * delta)
	
	return velocity

