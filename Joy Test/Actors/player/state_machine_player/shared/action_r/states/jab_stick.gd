extends "res://Actors/player/state_machine_player/shared/action_r/action_r.gd"


#Pose Variables
onready var RightArmController = owner.get_node("Body/Armature/Skeleton/RightArmController")
onready var RightArmController_idx = Skel.find_bone("RightArmController")


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	attached_facing_dir = get_attached_facing_dir(attached_obj)
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if attached_obj != null:
		if Input.is_action_just_pressed("jump"):
			emit_signal("state_switch", "jab_stick_jump")
		elif Input.is_action_just_pressed("attack_right"):
			attached_obj = null #Clear attached object after letting go
			continue_jab_anim(anim_pause_position)
		
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if attached_obj != null:
		rotate_player()
		rotate_arm()
	
	.update(delta)
	
	#Let go if player collides with object
	if owner.get_slide_count() > 0 and attached_obj != null:
		attached_obj = null
		continue_jab_anim(anim_pause_position)


func _on_animation_finished(anim_name):
	if anim_name == "jab_test":
		AnimStateMachineActionR.start("none")
		reset_arm_rotation()
		emit_signal("state_switch", "none")


func continue_jab_anim(anim_pause_position):
	AnimStateMachineActionR.start("jab_test")
	AnimTree.set("parameters/SeekActionR/seek_position", anim_pause_position)


func rotate_player():
	var arm_pos_cent : Vector3
	var look_at_dir : Vector3
	var look_at_point : Vector3
	
	#Save current arm global origin
	arm_pos_cent = RightArmController.get_global_transform().origin
	
	#Get new facing direction in global
	look_at_dir = attached_obj.to_global(attached_facing_dir) - attached_obj.get_global_transform().origin
	look_at_dir.y = 0
	look_at_dir = look_at_dir.normalized()
	
	look_at_point = Body.get_global_transform().origin + look_at_dir
	
	Body.look_at(look_at_point, Vector3(0,1,0))
	
	#Move body with arm by difference in arm pos after rotation
	var translate : Vector3
	
	translate = arm_pos_cent - RightArmController.get_global_transform().origin
	
	Body.translate(translate)


func rotate_arm():
	var look_at_point : Vector3
	var pose : Transform
	
	#Set arm custom pose back to default
	reset_arm_rotation()
	
	look_at_point = attached_obj.to_global(stick_point)
	
	#Create custom pose
	pose.origin = RightArmController.get_global_transform().origin
	pose.basis.x = Vector3(1,0,0)
	pose.basis.y = Vector3(0,1,0)
	pose.basis.z = Vector3(0,0,1)
	
	pose = pose.looking_at(look_at_point, Vector3(0,1,0))
	
	pose.origin = Vector3(0,0,0)
	pose = pose.rotated(Vector3(0,1,0), get_facing_direction_horizontal(Body).angle_to(Vector3(0,0,-1)))
	
	Skel.set_bone_custom_pose(RightArmController_idx, pose)


func reset_arm_rotation():
	var transform : Transform
	
	transform.origin = Vector3(0,0,0)
	transform.basis.x = Vector3(1,0,0)
	transform.basis.y = Vector3(0,1,0)
	transform.basis.z = Vector3(0,0,1)
	
	Skel.set_bone_custom_pose(RightArmController_idx, transform)


func get_attached_facing_dir(attached_obj):
	var facing_dir : Vector3
	var attached_facing_dir : Vector3
	
	facing_dir = get_facing_direction_horizontal(Body)
	
	attached_facing_dir = attached_obj.to_local(attached_obj.get_global_transform().origin + facing_dir)
	
	return attached_facing_dir










