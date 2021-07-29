extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"


#Jump Variables
var wall_jump_velocity = 32


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_can_wall_jump(false)
	Timer_Wall_Jump.stop()
	set_jumped(false)
	
#	anim_tree_play_anim("jump", AnimStateMachineMotion)
	
	#DEBUG
	jump()
	
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
	
	.update(delta)
	
	if owner.is_on_wall() and !can_wall_jump:
		check_can_wall_jump()


func _on_animation_finished(_anim_name):
	return


func jump():
	velocity = add_wall_jump_velocity(velocity, wall_col_normal)
	wall_col_normal = null


#Call this function in future animation
func add_wall_jump_velocity(velocity, wall_normal):
	var temp_vel : Vector3
	var rot_axis : Vector3
	
	rot_axis = Vector3(0,1,0).cross(wall_normal).normalized()
	
	temp_vel = Vector3(0, wall_jump_velocity, 0).rotated(rot_axis, deg2rad(40))
	
	snap_vector = Vector3(0,0,0) #disable snap vector so player can leave floor
	set_jumped(true)
	
	return temp_vel




