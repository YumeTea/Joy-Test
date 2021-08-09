extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"


'kick_off_ledge needs to abort anims'


signal on_ledge(on_ledge_flag)


const ledge_jump_speed = 32.0
const ledge_jump_angle = 50.0


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_jumped(false)
	
	hang_obj = grab_data["grab_obj"]
	hang_point = hang_obj.to_local(grab_data["grab_point"])
	hang_dir = hang_obj.to_local(grab_data["grab_dir"] + hang_obj.get_global_transform().origin)
	
	anim_tree_play_anim("ledge_jump_back", AnimStateMachineMotion)
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("cancel"):
		let_go_ledge()
		emit_signal("state_switch", "fall")
		return
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if grab_data["grab_point"] == null and !has_jumped:
		let_go_ledge()
		emit_signal("state_switch", "fall")
		return
	elif has_jumped and velocity.y <= 0.0:
		emit_signal("state_switch", "fall")
		return
	
	#Remove fasten v from total v
	velocity -= velocity_fasten
	
	#Counteract gravity
	velocity = Vector3(0,0,0)
	velocity.y = weight * gravity * delta
	
	.update(delta)


func _on_animation_finished(anim_name):
	return


func jump():
	if !has_jumped:
		var grab_dir = hang_obj.to_global(hang_dir) - hang_obj.get_global_transform().origin
		
		velocity += calc_ledge_jump_velocity()
		set_jumped(true)
		let_go_ledge()
		
		rotate_to_direction(-grab_dir)


#Call this function in future animation
func calc_ledge_jump_velocity():
	var jump_vel : Vector3
	
	var grab_dir = hang_obj.to_global(hang_dir) - hang_obj.get_global_transform().origin
	var rot_axis = -grab_dir.cross(Vector3(0,1,0)).normalized()
	jump_vel = -grab_dir.rotated(rot_axis, deg2rad(ledge_jump_angle)) * ledge_jump_speed
	
	return jump_vel

