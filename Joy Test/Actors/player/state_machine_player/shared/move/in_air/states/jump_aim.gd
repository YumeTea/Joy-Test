extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"


'player gets stuck in jump aim'
'slide issue'


#Jump Variables
var jump_velocity = 28


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_aiming(true)
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
	if is_aiming == false and has_jumped:
		emit_signal("state_switch", "fall")
	if velocity.y <= 0.0 and has_jumped:
		emit_signal("state_switch", "fall_aim")
		return
	
	rotate_to_direction(Vector2(0,-1).rotated(-camera_angles.y))
	
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

