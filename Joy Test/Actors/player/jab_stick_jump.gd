extends "res://Actors/player/state_machine_player/shared/action_r/action_r.gd"


#Node Storage
var Needle_Arm : Node


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	Needle_Arm = owner.get_node("Body").get_node("Needle_Arm")
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if attached_obj != null:
		rotate_player()
		rotate_arm()
	
	.update(delta)
	
	if owner.get_slide_count() > 0:
		attached_obj = null
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
	var look_at_dir : Vector3
	var look_at_point : Vector3
	
	look_at_dir = attached_obj.to_global(attached_facing_dir) - attached_obj.get_global_transform().origin
	look_at_dir.y = 0
	look_at_dir = look_at_dir.normalized()
	
	look_at_point = Body.get_global_transform().origin + look_at_dir
	
	Body.look_at(look_at_point, Vector3(0,1,0))


func get_attached_facing_dir(attached_obj):
	var facing_dir : Vector3
	var attached_facing_dir : Vector3
	
	facing_dir = get_facing_direction_horizontal(Body)
	
	attached_facing_dir = attached_obj.to_local(attached_obj.get_global_transform().origin + facing_dir)
	
	return attached_facing_dir










