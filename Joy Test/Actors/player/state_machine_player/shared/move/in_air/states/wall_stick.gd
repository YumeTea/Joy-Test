extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"

var attached_pos_current : Vector3
var attached_pos_prev : Vector3


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	velocity = Vector3(0,0,0)
	attached_pos_current = attached_obj.get_global_transform().origin
	attached_pos_prev = attached_obj.get_global_transform().origin
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("attack_right"):
		exit_stick_state()
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	velocity = calc_stick_velocity(velocity, delta)
	
	#Counteract gravity
	velocity.y -= (gravity * weight * delta)
	
	.update(delta)
	
	if owner.get_slide_count() > 0:
		exit_stick_state()


func _on_animation_finished(_anim_name):
	return


func calc_stick_velocity(velocity_current, delta):
	var velocity : Vector3
	
	attached_pos_current = attached_obj.get_global_transform().origin
	
	velocity = (attached_pos_current - attached_pos_prev) / delta
	velocity.y = velocity_current.y
	
	attached_pos_prev = attached_pos_current
	
	return velocity


func exit_stick_state():
	if is_aiming:
			emit_signal("state_switch", "fall_aim")
	elif !is_aiming:
		emit_signal("state_switch", "fall")



