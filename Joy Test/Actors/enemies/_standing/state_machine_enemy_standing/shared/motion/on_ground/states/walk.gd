extends "res://Actors/enemies/_standing/state_machine_enemy_standing/shared/motion/on_ground/on_ground.gd"

#Anim Constants
const anim_walk_bound = 3.0
const anim_run_bound = 10.0


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_fasten_to_floor(true)
	
	anim_tree_play_anim("walkrun", AnimStateMachineMotion)
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	#Remove fasten v from total v
	velocity -= velocity_fasten
	
	#Calc player velocity
	velocity = calc_walk_velocity(velocity, delta)
	
	#Set animation blend position
	set_walk_anim_blend(velocity)
	
	.update(delta)
	
	var vel_move = velocity - velocity_fasten
	if Vector2(vel_move.x, vel_move.z).length() < speed_thresh_lower and get_joystick_input_l().length() == 0.0:
		emit_signal("state_switch", "idle")
		return
	
	###SIMULATED BUFFERING###
	if Input.is_action_pressed("jump"):
		emit_signal("state_switch", "jump")
		return
	#####################################


func _on_animation_finished(_anim_name):
	return


###WALK FUNCTIONS###
func calc_walk_velocity(current_velocity, delta):
	var input : Vector2
	var input_direction : Vector2
	var velocity : Vector3
	
	#Get input
	input = get_joystick_input_l()
	
	#Get direction
	input_direction = input.rotated(-camera_angles.y)
	
	#Rotate player
	if !is_aiming:
		rotate_to_direction(input_direction)
	elif is_aiming:
		rotate_to_direction(Vector2(0,-1).rotated(-camera_angles.y))
	
	#Get next player velocity
	velocity = interp_walk_velocity(input_direction, current_velocity, delta)
	
	return velocity


###ANIMATION FUNCTIONS###
func set_walk_anim_blend(current_velocity):
	#Set blend between walk and run anims
	var blend_position : float
	var velocity_horizontal : Vector2
	
	velocity_horizontal = Vector2(current_velocity.x, -current_velocity.z)
	
	##Anim blend position calc
	#Walk
	if velocity_horizontal.length() <= anim_walk_bound:
		blend_position = 0.0
	#Walk/run blending
	elif velocity_horizontal.length() > anim_walk_bound and velocity_horizontal.length() < anim_run_bound:
		blend_position = 1 - ((anim_run_bound - velocity_horizontal.length()) / (anim_run_bound - anim_walk_bound))
	#Run
	elif velocity_horizontal.length() >= anim_run_bound:
		blend_position = 1.0
	
	#Set blend between walk/run
	AnimTree.set("parameters/BlendTreeMotion/StateMachineMotion/walkrun/blend_position", blend_position)
	
	#Set directional blend of walk and run anims
	var anim_speed : float #0-1
	var anim_direction : Vector2 #Normalized vector of velocity in relation to facing
	var anim_velocity : Vector2
	
	##Anim speed calc
	#Walk
	if blend_position == 0.0:
		anim_speed = velocity_horizontal.length() / anim_walk_bound * 0.4
	#Walk/run blend speed
	elif blend_position > 0.0 and blend_position < 1.0:
		var bound_lower = 0.4
		var bound_upper = anim_run_bound / run_speed_full
		anim_speed = ((bound_upper - bound_lower) * blend_position) + bound_lower
	#Run
	elif blend_position == 1.0:
		anim_speed = velocity_horizontal.length() / run_speed_full
	
	##Anim direction calc
	anim_direction = velocity_horizontal.rotated(-Body.get_rotation().y).normalized()
	
	#Set time scale and direction of walk/run
	AnimTree.set("parameters/BlendTreeMotion/TimeScaleMotion/scale", anim_speed)
	AnimTree.set("parameters/BlendTreeMotion/StateMachineMotion/walkrun/0/blend_position", anim_direction)
	AnimTree.set("parameters/BlendTreeMotion/StateMachineMotion/walkrun/1/blend_position", anim_direction)
	












