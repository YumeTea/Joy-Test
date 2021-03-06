extends "res://Actors/player/camera_rig/state_machine_camera_rig/camera/camera.gd"


'Should the aim state stack? probably not'


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_camera_offset("Aim")
	
	set_camera_ui(true)
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	set_camera_ui(false)
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if event is InputEventMouseMotion:
		input_gyro_r = get_gyro_input_r(event)
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	#Exit aim state handling
	if Input.is_action_just_pressed("cancel"):
		emit_signal("state_switch", "default")
		return
	if !is_aiming: #this line is for immediately exiting aim state instead of waiting for timer
		if Input.is_action_just_pressed("attack_left") or Input.is_action_just_pressed("attack_right"):
			emit_signal("state_switch", "default")
			return
	
	input_stick_r = get_joystick_input_r()
	
	if Input.is_action_pressed("aim_r"):
		camera_input = get_camera_input(input_stick_r, input_gyro_r)
	else:
		camera_input = get_camera_input(input_stick_r, Vector2(0,0))
		
	.update(delta)


func _on_animation_finished(_anim_name):
	return



func get_camera_input(input_stick, input_gyro):
	var input : Vector2
	
	input = (input_stick + input_gyro)
	
	return input










