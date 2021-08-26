extends "res://Actors/player/state_machine_player/shared/move/on_ground/on_ground.gd"


#const turn_angle_min : float = 0.006
const turn_angle_min : float = 0.006
const turn_angle_max : float = 0.02
const slide_turn_bound_lower : float = 0.0
const slide_turn_bound_upper : float = 32.0

#const snap_vector_slide = Vector3(0,-2,0)
const floor_angle_slide = deg2rad(85.0)

var floor_stick_normal : Vector3


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	#Zero out fasten velocity in states where player is not fastened
	velocity_fasten = Vector3(0,0,0)
	set_stop_on_slope(false)
	set_floor_angle_max(floor_angle_slide)
	set_fasten_to_floor(false)
	
	floor_stick_normal = owner.get_floor_normal()
	
	#Start anim
	anim_tree_play_anim("barrier_slide", AnimStateMachineMotion)
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	set_stop_on_slope(true)
	set_floor_angle_max(floor_angle_max_default)
#	set_fasten_to_floor(true)
	
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if !is_b_sliding:
		emit_signal("state_switch", "walk")
		return
	
	velocity = calc_slide_velocity(velocity, owner.get_floor_normal(), delta)
	
	.update(delta)
	
	###SIMULATED BUFFERING###
	if Input.is_action_pressed("jump"):
		emit_signal("state_switch", "jump")
		return
	#####################################


func _on_animation_finished(anim_name):
	._on_animation_finished(anim_name)


func calc_slide_velocity(current_velocity, floor_normal, delta):
	var input : Vector2
	var input_dir : Vector2
	var input_angle : float
	var turn_angle : float
	var vel_temp : Vector3
	
	#Store temp velocity
	vel_temp = current_velocity
	
	#Get input
	input = get_joystick_input_l()
	
	#Get direction
	input_dir = input.rotated(-camera_angles.y)
	
	#Get angle between facing and input
	input_angle = Vector2(vel_temp.x, vel_temp.z).angle_to(input_dir)
	
	#Rotate player
	if !is_aiming:
		pass
	elif is_aiming:
		rotate_to_direction(Vector2(0,-1).rotated(-camera_angles.y))
	
	#Interpolate turn angle based on velocity (easier to turn at lower velocity)
	var vel_value = vel_temp.length() - slide_turn_bound_lower
	var interp = 1.0 - (vel_value / (slide_turn_bound_upper - slide_turn_bound_lower))
	interp = clamp(interp, turn_angle_min/turn_angle_max, 1.0)
	
	turn_angle = turn_angle_max * interp * input.length() * sign(-input_angle)
	
	#Rotate temp vel
	vel_temp = vel_temp.rotated(floor_normal, turn_angle)
	
	return vel_temp
	
	
	
	
	
	
	
	


