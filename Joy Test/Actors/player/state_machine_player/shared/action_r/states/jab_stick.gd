extends "res://Actors/player/state_machine_player/shared/action_r/action_r.gd"


'Disconnect in anim continuation when letting go'


#Pose Variables
onready var RightArmController = owner.get_node("Body/Armature/Skeleton/RightArmController")


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
	if anim_name == "jab":
		AnimStateMachineActionR.start("none")
		reset_custom_pose_r_arm()
		emit_signal("state_switch", "none")


func continue_jab_anim(anim_pause_position):
	AnimStateMachineActionR.start("jab")
	AnimTree.set("parameters/SeekActionR/seek_position", anim_pause_position)


#Rotates and moves player around RightArmController to face attach point
'This should be in the move state machine'
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
	translate = translate.rotated(Vector3(0,1,0), -Body.get_rotation().y)
	
#	owner.global_translate(translate)
	owner.move_and_collide(translate)


func rotate_arm():
	var look_at_point : Vector3
	var pose : Transform
	
	#Set arm custom pose back to default
	reset_custom_pose_r_arm()
	
	#Orient look at point
	look_at_point = attached_obj.to_global(stick_point)
	look_at_point -= RightArmController.get_global_transform().origin #Set look at point to local terms of arm controller
	look_at_point = look_at_point.rotated(Vector3(0,1,0), -Body.get_rotation().y)
	
	#Create custom pose
	pose.origin = Vector3(0,0,0)
	pose.basis = Basis(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1))
	
	pose = pose.looking_at(look_at_point, Vector3(0,1,0))
	
	#Apply custom pose
	Skel.set_bone_custom_pose(RightArmController_idx, pose)
	
	#Debug
	Debug_Point.global_transform.origin = attached_obj.to_global(stick_point)


func get_attached_facing_dir(attached_obj):
	var facing_dir : Vector3
	var attached_facing_dir : Vector3
	
	facing_dir = get_facing_direction_horizontal(Body)
	
	attached_facing_dir = attached_obj.to_local(attached_obj.get_global_transform().origin + facing_dir)
	
	return attached_facing_dir










