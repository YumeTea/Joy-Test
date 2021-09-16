extends "res://Actors/camera_main/state_machine_camera_main/shared/shared.gd"


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	set_camera_target(null)
	
	.exit()


#Creates output based on the input event passed in
func handle_input(_event):
	return


#Acts as the _process method would
func update(delta):
	.update(delta)


func _on_animation_finished(_anim_name):
	return
