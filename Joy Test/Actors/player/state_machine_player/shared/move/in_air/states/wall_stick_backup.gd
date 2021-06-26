extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"


'player annoyingly snaps into position at certain rotation changes'







var attached_pos_current : Vector3
var attached_pos_prev : Vector3

var attached_rot_current : Vector3
var attached_rot_prev : Vector3


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	velocity = Vector3(0,0,0)
	attached_pos_current = attached_obj.get_global_transform().origin
	attached_pos_prev = attached_obj.get_global_transform().origin
	attached_rot_current = attached_obj.get_global_transform().basis.get_rotation_quat().get_euler()
	attached_rot_prev = attached_obj.get_global_transform().basis.get_rotation_quat().get_euler()
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("attack_right"):
		exit_stick_state()
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	velocity = calc_stick_velocity(velocity, delta)
	
	#Counteract gravity
	velocity.y -= (gravity * weight * delta)
	
	.update(delta)
	
	if owner.get_slide_count() > 0:
		exit_stick_state()


func _on_animation_finished(_anim_name):
	return


func calc_stick_velocity(velocity_current, delta):
	var pos_current : Vector3 #position relative to attached object origin
	var pos_next : Vector3
	var velocity : Vector3
	
	
	###VELOCITY DUE TO TRANSLATION
	attached_pos_current = attached_obj.get_global_transform().origin
	
	velocity = (attached_pos_current - attached_pos_prev) / delta
	
	attached_pos_prev = attached_pos_current
	
	
	###VELOCITY DUE TO ROTATION
	attached_rot_current = attached_obj.get_global_transform().basis.get_rotation_quat().get_euler()
	
	var rot_change = calc_rotation_change(attached_rot_current, attached_rot_prev)
#	print(rad2deg(rot_change.x))
	
	pos_current = owner.get_global_transform().origin - attached_obj.get_global_transform().origin
	
	pos_next = pos_current
	
	pos_next = pos_next.rotated(Vector3(1,0,0), rot_change.x)
	pos_next = pos_next.rotated(Vector3(0,1,0), rot_change.y)
	pos_next = pos_next.rotated(Vector3(0,0,1), rot_change.z)
	
	velocity += (pos_next - pos_current) / delta
	
	
	attached_rot_prev = attached_rot_current
	
	return velocity


func exit_stick_state():
	if is_aiming:
			emit_signal("state_switch", "fall_aim")
	elif !is_aiming:
		emit_signal("state_switch", "fall")


func calc_rotation_change(rot_current : Vector3, rot_prev : Vector3):
	var angles_clamped : Vector3
	
	#X
	if abs(rot_current.x - rot_prev.x) > PI / 2:
		angles_clamped.x = -(PI - abs(rot_current.x - rot_prev.x))
	else:
		angles_clamped.x = (rot_current.x - rot_prev.x)
		print(angles_clamped.x)
	#Y
	if abs(rot_current.y - rot_prev.y) > PI / 2:
		angles_clamped.y = -(PI - abs(rot_current.y - rot_prev.y))
	else:
		angles_clamped.y = (rot_current.y - rot_prev.y)
	#Z
	if abs(rot_current.z - rot_prev.z) > PI / 2:
		angles_clamped.z = -(PI - abs(rot_current.z - rot_prev.z))
	else:
		angles_clamped.z = (rot_current.z - rot_prev.z)
	
	return angles_clamped





