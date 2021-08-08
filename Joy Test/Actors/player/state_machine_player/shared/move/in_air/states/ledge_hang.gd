extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"


signal on_ledge(on_ledge_flag)


#Node Storage
onready var LedgeHangStateMachine = owner.get_node("AnimationTree").get("parameters/BlendTreeMotion/StateMachineMotion/ledge_hang/playback")

#Ledge Hang Variables
var hang_obj : Node
var hang_point : Vector3
var hang_dir : Vector3
var ledge_up : Vector3
var velocity_move : Vector3
#var velocity_fasten : Vector3

#Ledge Hang Flags
var moving = false


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	#Set initial values
	velocity = Vector3(0,0,0)
	velocity_fasten = Vector3(0,0,0)
	set_can_wall_jump(false)
	set_arm_r_occupied(true)
	
	hang_obj = grab_data["grab_obj"]
	hang_point = hang_obj.to_local(grab_data["grab_point"])
	
	#Move player to ledge hang position
	snap_to_ledge(hang_obj, hang_point, grab_data["grab_dir"])
	
	emit_signal("on_ledge", true)
	
	#Start anim
	anim_tree_play_anim("ledge_hang", AnimStateMachineMotion)
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("jump"):
		var facingdotinput = Vector2(grab_data["grab_dir"].x, grab_data["grab_dir"].z).dot(get_input_dir_l())
		if facingdotinput >= 0.0:
			emit_signal("state_switch", "ledge_get_up")
			return
		else:
			emit_signal("state_switch", "ledge_jump_back")
			return
	elif Input.is_action_just_pressed("cancel"):
		let_go_ledge()
		emit_signal("state_switch", "fall")
		return
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if grab_data["grab_point"] == null:
		let_go_ledge()
		emit_signal("state_switch", "fall")
		return
	
	velocity = calc_ledge_velocity(delta)
	
	set_ledge_hang_anim_blend(velocity_move)
	
	.update(delta)


func _on_animation_finished(anim_name):
	return


func calc_ledge_velocity(delta):
	var new_vel = Vector3(0,0,0)
	
	#Calc ledge movement velocity
	velocity_move = (velocity - velocity_fasten)
	velocity_move = interp_ledge_move_velocity(velocity_move, delta)
	#Move grab point by move velocity
	hang_point += hang_obj.to_local((velocity_move * delta) + hang_obj.get_global_transform().origin)
	#Assign move velocity to total velocity
	new_vel = velocity_move
	
	#Calc ledge attachment velocity
	velocity_fasten = fasten_to_ledge(hang_obj, hang_point, grab_data["grab_dir"], delta)
	new_vel += velocity_fasten
	
	#Counteract gravity
	new_vel.y -= (gravity * weight * delta)
	
	return new_vel


#Returns velocity along grab dir cross up
func interp_ledge_move_velocity(current_move_vel, delta):
	var input_dir : Vector2
	var grab_dir : Vector3
	var move_vec : Vector3
	var move_dir : Vector2
	var temp_vel = Vector3(0,0,0)
	var target_vel = Vector3(0,0,0)
	var new_vel = Vector3(0,0,0)
	
	#Get move vec
	move_vec = grab_data["ledge_move_dir"]
	
	#Get move direction
	input_dir = get_input_dir_l()
	move_dir = Vector2(move_vec.x, move_vec.z).normalized().dot(input_dir) * Vector2(move_vec.x, move_vec.z).normalized()
	
	#Get current move velocity
	temp_vel = current_move_vel
	
	#Get portion of velocity that is pointing in input direction
	var dirdotvel = move_dir.normalized().dot(Vector2(temp_vel.x, temp_vel.z).normalized())
	dirdotvel = clamp(dirdotvel, 0, 1)
	if dirdotvel >= 0.995:
		target_vel = move_dir.normalized() * (temp_vel.length())
	else:
		target_vel = move_dir.normalized() * (temp_vel.length() * dirdotvel)
	
	#Solve for current t
	var t : float
	var t_to_full = ledge_move_full_time / 2
	var x = 1.0/3.0
	t = pow((target_vel.length() / ledge_move_speed_full), (1.0/x)) * ledge_move_full_time
	t = clamp(t, 0, ledge_move_full_time)
	
	#Solve for target velocity
	var target_t : float
	var target_speed : float
	target_t = clamp(t + delta, 0, ledge_move_full_time)
	target_speed = (pow((target_t / ledge_move_full_time), x) * ledge_move_speed_full)
	
	target_vel = Vector3(move_dir.x, 0, move_dir.y)
	target_vel *= target_speed
	
	#Step current velocity to target velocity
	var step_vel : Vector3
	var step_mag : float
	
	if temp_vel.length() <= target_vel.length() or is_equal_approx(temp_vel.length(), target_vel.length()):
		step_vel = (target_vel - temp_vel)
	else:
		step_mag = min(2.4, (target_vel - temp_vel).length())
		
		step_vel = (target_vel - temp_vel).normalized() * step_mag
	
	#Set new velocity pointing in move_vec direction
	new_vel = temp_vel + step_vel
	var veldotmove = new_vel.dot(move_vec)
	
	if veldotmove >= 0.0:
		new_vel = new_vel.length() * move_vec
	elif veldotmove < 0.0:
		new_vel = new_vel.length() * -move_vec
	
#	#Move grab point by velocity
#	hang_point += hang_obj.to_local((new_vel * delta) + hang_obj.get_global_transform().origin)
	
	return new_vel


#Does not apply velocity when snapping to ledge grab point
func snap_to_ledge(hang_obj, hang_point, face_dir):
	var grab_point : Vector3
	var grab_dir : Vector3
	
	grab_point = hang_obj.to_global(hang_point)
	grab_dir = face_dir
	
	rotate_to_direction(Vector2(grab_dir.x, grab_dir.z))
	
	var translate = grab_point - Ledge_Grab_Position.get_global_transform().origin
	
	owner.global_translate(translate)


#Applies velocity while following ledge grab point
func fasten_to_ledge(hang_obj, hang_point, face_dir, delta):
	var grab_point : Vector3
	var grab_dir : Vector3
	var vel_new : Vector3
	var angle : float
	
	grab_point = hang_obj.to_global(hang_point)
	grab_dir = face_dir
	
	rotate_about_grab_point(grab_point, Vector2(grab_dir.x, grab_dir.z))
	
	vel_new = (grab_point - Ledge_Grab_Position.get_global_transform().origin) / delta
	
	return vel_new


###ANIMATION FUNCTIONS###
func set_ledge_hang_anim_blend(current_velocity : Vector3):
	var move_blend : float
	var anim_speed : float
	
	#Determine idle/move blend
	if current_velocity.length() > 0.0:
		if LedgeHangStateMachine.is_playing():
			LedgeHangStateMachine.travel("ledge_move")
		else:
			LedgeHangStateMachine.start("ledge_move")
		moving = true
	else:
		#Reset motion anim time scale when going back to idle ledge hang
		AnimTree.set("parameters/BlendTreeMotion/TimeScaleMotion/scale", 1.0)
		
		if LedgeHangStateMachine.is_playing():
			LedgeHangStateMachine.travel("ledge_hang")
		else:
			LedgeHangStateMachine.start("ledge_hang")
		moving = false
	
	#Set move blend if necessary
	if moving:
		move_blend = current_velocity.normalized().dot(grab_data["ledge_move_dir"])
		
		anim_speed = (current_velocity.length() / ledge_move_speed_full) * 1.675
		
		AnimTree.set("parameters/BlendTreeMotion/StateMachineMotion/ledge_hang/ledge_move/blend_position", move_blend)
		AnimTree.set("parameters/BlendTreeMotion/TimeScaleMotion/scale", anim_speed)













