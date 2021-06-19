extends "res://Actors/player/camera_rig/state_machine_camera_rig/camera/camera.gd"


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(_event):
	return


#Acts as the _process method would
func update(delta):
	.update(delta)


func _on_animation_finished(_anim_name):
	return


