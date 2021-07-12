extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"

'need to prevent player from climbing higher using this state'
'player should fail to jump if they collide with the level before jumping'

#Jump Variables
var jump_angle = deg2rad(68)
var jump_speed = 38


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_jumped(false)
	
	AnimStateMachineMotion.start("stick_jump")
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	#Counteract gravity before jumping
	if !has_jumped:
		velocity.y -= (gravity * weight * delta)
	else:
		velocity = calc_aerial_velocity(velocity, delta)
	
	.update(delta)


func _on_animation_finished(anim_name):
	if anim_name == "stick_jump":
		AnimStateMachineMotion.start("none")
		if is_aiming:
			emit_signal("state_switch", "fall_aim")
		elif !is_aiming:
			emit_signal("state_switch", "fall")


func calc_air_speed(velocity):
	pass


func jump():
	velocity = add_jump_velocity(velocity)
	set_jumped(true)


#Call this function in future animation
func add_jump_velocity(velocity):
	var jump_velocity : Vector3
	
	jump_velocity = Vector3(0,0,-jump_speed).rotated(Vector3(1,0,0), jump_angle)
	jump_velocity = jump_velocity.rotated(Vector3(0,1,0), Body.get_rotation().y)
	
	velocity += jump_velocity
	snap_vector = Vector3(0,0,0) #disable snap vector so player can leave floor
	
	return velocity




