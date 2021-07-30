extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"


#Jump Variables
var wall_jump_velocity = 32
var wall_jump_direction : Vector3


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	#Force exit aim state if in aim state
	set_can_aim(false)
	set_arm_l_occupied(true)
	set_arm_r_occupied(true)
	
	#Reset can wall jump flag and reset has jumped flag
	set_can_wall_jump(false)
	Timer_Wall_Jump.stop()
	set_jumped(false)
	
	wall_jump_direction = calc_wall_jump_direction(wall_col)
	rotate_to_direction(Vector2(wall_jump_direction.x, wall_jump_direction.z).normalized())
	
#	anim_tree_play_anim("jump", AnimStateMachineMotion)
	
	#DEBUG
	jump()
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	#DEBUG
	set_arm_l_occupied(false)
	set_arm_r_occupied(false)
	set_can_aim(true)
	
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
	velocity = calc_wall_jump_velocity((wall_col.travel + wall_col.remainder), wall_jump_direction)
	set_wall_col(null)


#func calc_wall_jump_direction(current_velocity, wall_normal):
#	var temp_vel : Vector3
#	var temp_normal : Vector3
#	var def_angle : float
#	var def_direction : Vector3
#
#	temp_vel = current_velocity
#	temp_vel.y = 0.0
#	temp_normal = wall_normal
#	temp_normal.y = 0.0
#
#	def_angle = temp_vel.angle_to(-temp_normal)
#
#	def_direction = temp_normal.rotated(Vector3(0,1,0), def_angle)
#	def_direction = def_direction.normalized()
#
#	return def_direction


func calc_wall_jump_direction(wall_collision : KinematicCollision):
	var temp_vel : Vector3
	var temp_normal : Vector3
	var def_angle : float
	var def_direction : Vector3
	
	temp_vel = wall_collision.travel + wall_collision.remainder
	temp_vel.y = 0.0
	temp_normal = wall_collision.normal
	temp_normal.y = 0.0
	
	def_angle = Vector2(temp_normal.x, temp_normal.z).angle_to(Vector2(temp_vel.x, temp_vel.z))
	def_angle = (PI * sign(def_angle)) - def_angle
	
	def_direction = temp_normal.rotated(Vector3(0,1,0), -def_angle)
	def_direction = def_direction.normalized()
	
	return def_direction


func calc_wall_jump_velocity(current_velocity, wall_jump_direction):
	var temp_vel : Vector3
	var rot_axis : Vector3
	
	rot_axis = Vector3(0,1,0).cross(wall_jump_direction).normalized()
	temp_vel = wall_jump_direction * wall_jump_velocity
	temp_vel = temp_vel.rotated(rot_axis, deg2rad(-40))
	
	snap_vector = Vector3(0,0,0) #disable snap vector so player can leave floor
	set_jumped(true)
	
	return temp_vel


#func add_wall_jump_velocity(velocity, wall_normal):
#	var temp_vel : Vector3
#	var rot_axis : Vector3
#
#	rot_axis = Vector3(0,1,0).cross(wall_normal).normalized()
#
#	temp_vel = Vector3(0, wall_jump_velocity, 0).rotated(rot_axis, deg2rad(40))
#
#	snap_vector = Vector3(0,0,0) #disable snap vector so player can leave floor
#	set_jumped(true)
#
#	return temp_vel




