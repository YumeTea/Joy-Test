extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"


var attached_pos : Vector3


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	velocity = Vector3(0,0,0)
	attached_pos = attached_obj.to_local(owner.get_global_transform().origin)
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("jump"):
		emit_signal("state_switch", "stick_jump")
		return
	elif Input.is_action_just_pressed("attack_right"):
		exit_stick_state()
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	velocity = calc_stick_velocity(delta)
	
	#Counteract gravity
	velocity.y -= (gravity * weight * delta)
	
	.update(delta)
	
	if owner.get_slide_count() > 0:
		exit_stick_state()


func _on_animation_finished(_anim_name):
	return


func calc_stick_velocity(delta):
	var pos_current : Vector3 #position relative to attached object origin
	var pos_next : Vector3
	var velocity : Vector3
	
	pos_current = owner.get_global_transform().origin
	pos_next = attached_obj.to_global(attached_pos)
	
	
	velocity = (pos_next - pos_current) / delta
	
	return velocity


func exit_stick_state():
	if is_aiming:
			emit_signal("state_switch", "fall_aim")
			return
	elif !is_aiming:
		emit_signal("state_switch", "fall")
		return





