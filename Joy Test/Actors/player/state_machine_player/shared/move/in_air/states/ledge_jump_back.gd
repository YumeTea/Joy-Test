extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"


'kick_off_ledge needs to abort anims'


signal on_ledge(on_ledge_flag)


const ledge_jump_speed = 26.0
const ledge_jump_angle = 50.0

var hang_obj : Node
var attached_point : Vector3
var attached_dir : Vector3
var ledge_up : Vector3
var velocity_fasten : Vector3


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_jumped(false)
	
	hang_obj = grab_data["grab_obj"]
	attached_point = hang_obj.to_local(grab_data["grab_point"])
	attached_dir = hang_obj.to_local(grab_data["grab_dir"] + hang_obj.get_global_transform().origin)
	
	###DEBUG
	jump()
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("cancel"):
		let_go_ledge()
		emit_signal("state_switch", "fall")
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if grab_data["grab_point"] == null and !has_jumped:
		let_go_ledge()
		emit_signal("state_switch", "fall")
		return
	elif has_jumped and velocity.y <= 0.0:
		emit_signal("state_switch", "fall")
		return
	
	if !has_jumped:
		velocity = calc_ledge_velocity(delta)
	
	.update(delta)


func _on_animation_finished(anim_name):
	return


func calc_ledge_velocity(delta):
	var new_vel = Vector3(0,0,0)
	
	#Calc ledge attachment velocity
	velocity_fasten = fasten_to_ledge(hang_obj, attached_point, grab_data["grab_dir"], delta)
	new_vel += velocity_fasten
	
	#Counteract gravity
	new_vel.y -= (gravity * weight * delta)
	
	return new_vel


#Applies velocity while following ledge grab point
func fasten_to_ledge(hang_obj, attached_point, face_dir, delta):
	var grab_point : Vector3
	var grab_dir : Vector3
	var vel_new : Vector3
	var angle : float
	
	grab_point = hang_obj.to_global(attached_point)
	grab_dir = hang_obj.to_global(attached_dir) - hang_obj.get_global_transform().origin
	
	rotate_about_grab_point(grab_point, Vector2(grab_dir.x, grab_dir.z))
	
	vel_new = (grab_point - Ledge_Grab_Position.get_global_transform().origin) / delta
	
	return vel_new


func let_go_ledge():
	set_can_ledge_grab(false)
	Timer_Ledge_Grab.start()
	emit_signal("on_ledge", false)


func jump():
	if !has_jumped:
		var grab_dir = hang_obj.to_global(attached_dir) - hang_obj.get_global_transform().origin
		
		velocity += calc_ledge_jump_velocity()
		set_jumped(true)
		let_go_ledge()
		
		rotate_to_direction(-grab_dir)


#Call this function in future animation
func calc_ledge_jump_velocity():
	var jump_vel : Vector3
	
	var grab_dir = hang_obj.to_global(attached_dir) - hang_obj.get_global_transform().origin
	var rot_axis = -grab_dir.cross(Vector3(0,1,0)).normalized()
	jump_vel = -grab_dir.rotated(rot_axis, deg2rad(ledge_jump_angle)) * ledge_jump_speed
	
	return jump_vel

