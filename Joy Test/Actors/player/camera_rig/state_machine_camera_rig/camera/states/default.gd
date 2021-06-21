extends "res://Actors/player/camera_rig/state_machine_camera_rig/camera/camera.gd"


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_camera_offset("Default")
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if Input.is_action_just_pressed("aim_r"):
		emit_signal("state_switch", "aim")
	
	input_stick_r = get_joystick_input_r()
	camera_input = get_camera_input(input_stick_r)
	
	.update(delta)


func _on_animation_finished(_anim_name):
	return


func get_camera_input(input_stick_r):
	var input : Vector2
	
	input = input_stick_r
	
	return input




