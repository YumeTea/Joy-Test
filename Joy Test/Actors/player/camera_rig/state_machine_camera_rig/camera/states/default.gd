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
	input_r = get_camera_input()
	
	.update(delta)
	
	if Input.is_action_pressed("aim_r"):
		emit_signal("state_switch", "aim")


func _on_animation_finished(_anim_name):
	return


func get_camera_input():
	var input : Vector2
	
	input = get_joystick_input_r()
	
	return input




