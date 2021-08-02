extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	snap_to_ledge(grab_point, grab_dir)
	velocity = Vector3(0,0,0)
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("cancel"):
		set_can_ledge_grab(false)
		Timer_Ledge_Grab.start()
		emit_signal("state_switch", "fall")
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	return


func _on_animation_finished(anim_name):
	return


func snap_to_ledge(grab_point, grab_dir):
	rotate_to_direction(Vector2(grab_dir.x, grab_dir.z))
	
	var translate = grab_point - Ledge_Grab_Position.get_global_transform().origin
	
	owner.global_translate(translate)

