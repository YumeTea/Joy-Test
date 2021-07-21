extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"


#Jump Variables
var jump_velocity = 24


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_jumped(false)
	
	AnimStateMachineMotion.travel("jump")
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if is_aiming and has_jumped:
		emit_signal("state_switch", "fall_aim")
		return
	if velocity.y <= 0.0 and has_jumped:
		emit_signal("state_switch", "fall")
		return
	
	if !owner.is_on_floor():
		velocity = calc_aerial_velocity(velocity, delta)
	
	.update(delta)


func _on_animation_finished(_anim_name):
	return


func calc_air_speed(velocity):
	pass


func jump():
	velocity = add_jump_velocity(velocity)


#Call this function in future animation
func add_jump_velocity(velocity):
	velocity.y = jump_velocity
	snap_vector = Vector3(0,0,0) #disable snap vector so player can leave floor
	set_jumped(true)
	
	return velocity




