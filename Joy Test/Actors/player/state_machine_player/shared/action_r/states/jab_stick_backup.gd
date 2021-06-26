extends "res://Actors/player/state_machine_player/shared/action_r/action_r.gd"

var rot_origin : Vector3

var rot_attached_current : Vector3
var rot_attached_prev : Vector3

var attached_facing_point : Vector3

#Node Storage
var Needle_Arm : Node


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	Needle_Arm = owner.get_node("Body").get_node("Needle_Arm")
	
	attached_facing_point = get_attached_facing_point(attached_obj)
	
	rot_origin = Body.get_global_transform().basis.get_rotation_quat().get_euler()
	rot_attached_current = attached_obj.get_global_transform().basis.get_rotation_quat().get_euler()
	rot_attached_prev = attached_obj.get_global_transform().basis.get_rotation_quat().get_euler()
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("attack_right"):
		attached_obj = null #Clear attached object after letting go
		continue_jab_anim()
		
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if attached_obj != null:
		rotate_player()
		rotate_arm()
	
	.update(delta)
	
	if owner.get_slide_count() > 0:
		continue_jab_anim()


func _on_animation_finished(anim_name):
	if anim_name == "jab_test":
		reset_arm_rotation()
		emit_signal("state_switch", "none")


func continue_jab_anim():
	Anim_Player.play()


func rotate_arm():
	var look_at_point : Vector3
	var transform_new : Transform
	
	look_at_point = attached_obj.to_global(stick_point)
	
	transform_new = Needle_Arm.get_global_transform().looking_at(look_at_point, Vector3(0,1,0))
	
	Needle_Arm.set_global_transform(transform_new)


func reset_arm_rotation():
	Needle_Arm.set_rotation(Vector3(0,0,0))


func rotate_player():
	var rot_change : Vector3
	
	rot_attached_current = attached_obj.get_global_transform().basis.get_rotation_quat().get_euler()
	
	rot_change = calc_rotation_change(rot_attached_current, rot_attached_prev)
	print(rad2deg(rot_change.y))
	
	rot_attached_prev = rot_attached_current
	
	Body.rotate_y(rot_change.y)


func get_attached_facing_point(attached_obj):
	var facing_dir : Vector3
	var attached_facing_point : Vector3
	
	facing_dir = get_facing_direction_2d(Body)
	
	attached_facing_point = attached_obj.to_local(Body.get_global_transform().origin + facing_dir)
	
	return attached_facing_point


#func calc_rotation_change(rot_current, rot_prev):
#	var rot_change : Vector3
#	var vec1 : Vector2
#	var vec2 : Vector2
#
#	rot_change = rot_current - rot_prev
#
#	#X
#
#	#Y
#	vec1 = Vector2(1,0).rotated(rot_prev.y)
#	vec2 = Vector2(1,0).rotated(rot_current.y)
#
#	rot_change.y = vec1.angle_to(vec2)
#
#
#
#
#
#	#Z
#
#	return rot_change


func calc_rotation_change(rot_current, rot_prev):
	var rot_change : Vector3
	
	rot_change = rot_current - rot_prev
	
	#X
	if rot_change.x > PI / 2:
		rot_change.x -= PI
		if rot_change.x > PI / 2:
			rot_change.x -= PI
	elif rot_change.x < -PI / 2:
		rot_change.x += PI
		if rot_change.x < -PI / 2:
			rot_change.x += PI
	#Y
	if rot_change.y > PI / 2:
		rot_change.y -= PI
		if rot_change.y > PI / 2:
			rot_change.y -= PI
	elif rot_change.y < -PI / 2:
		rot_change.y += PI
		if rot_change.y < -PI / 2:
			rot_change.y += PI
	#Z
	if rot_change.z > PI / 2:
		rot_change.z -= PI
		if rot_change.z > PI / 2:
			rot_change.z -= PI
	elif rot_change.z < -PI / 2:
		rot_change.z += PI
		if rot_change.z < -PI / 2:
			rot_change.z += PI
	
	return rot_change










