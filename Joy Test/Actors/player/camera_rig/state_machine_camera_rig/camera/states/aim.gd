extends "res://Actors/player/camera_rig/state_machine_camera_rig/camera/camera.gd"


'Should the aim state stack? probably not'


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	#This should be its own function
	var pivot_translation = Pivot_Points.get_node("Aim").get_translation()
	Pivot.set_translation(pivot_translation)
	
	var camera_translation = Camera_Points.get_node("Aim").get_translation()
	Camera_Pos.set_translation(camera_translation)
	
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


#Acts as the _process method would
func update(delta):
	input_stick_r = get_joystick_input_r()
	
	if input_stick_r.length() > 0 or input_gyro_r.length() > 0:
		camera_input = get_camera_input(input_stick_r, input_gyro_r)
		
		.update(delta)
	
	if Input.is_action_just_pressed("cancel"):
		emit_signal("state_switch", "default")


func _on_animation_finished(_anim_name):
	return



func get_camera_input(input_stick, input_gyro):
	var input : Vector2
	
	input = (input_stick + input_gyro)
	
	return input










