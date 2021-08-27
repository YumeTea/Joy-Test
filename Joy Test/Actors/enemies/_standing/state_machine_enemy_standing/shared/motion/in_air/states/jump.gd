extends "res://Actors/enemies/_standing/state_machine_enemy_standing/shared/motion/in_air/in_air.gd"


#Jump Variables
var jump_speed = 24


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	#Zero out fasten velocity in states where player is not fastened
	velocity_fasten = Vector3(0,0,0)
	
	set_jumped(false)
	
	anim_tree_play_anim("jump", AnimStateMachineMotion)
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if velocity.y <= 0.0 and has_jumped:
		emit_signal("state_switch", "fall")
		return
	
	if !owner.is_on_floor(): #Check if on floor so jump squat does not use aerial velocity
		velocity = calc_aerial_velocity(velocity, delta)
	
	.update(delta)


func _on_animation_finished(_anim_name):
	return


func jump():
	if !has_jumped:
		velocity += calc_jump_velocity()
		set_snap_vector(Vector3(0,0,0))
		set_jumped(true)


#Call this function in future animation
func calc_jump_velocity():
	var jump_vel = Vector3(0.0, jump_speed, 0.0)
	
	return jump_vel




