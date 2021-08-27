extends "res://Actors/enemies/_standing/state_machine_enemy_standing/shared/action_r/action_r.gd"


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_arm_r_occupied(true)
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	set_arm_r_occupied(false)
	
	.exit()


#Creates output based on the input event passed in
func handle_input(_event):
	return


#Acts as the _process method would
func update(_delta):
	if !arm_r_occupied:
		emit_signal("state_switch", "none")
		return


func _on_animation_finished(_anim_name):
	return

