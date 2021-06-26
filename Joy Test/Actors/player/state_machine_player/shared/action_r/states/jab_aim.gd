extends "res://Actors/player/state_machine_player/shared/action_r/action_r.gd"


#Jab Variables
var jab_strength = 56

var arm_transform_default : Transform
var aim_interp_radius_inner = 7
var aim_interp_radius_outer = 12

#Node Storage
var Needle_Arm : Node


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_hit(false)
	
	Needle_Arm = owner.get_node("Body").get_node("Needle_Arm")
	
	
	Needle_Arm.connect("raycast_collided", self, "_on_jab_collision")
	aim_arm_transform(camera_look_at_point)
	Anim_Player.play("jab_test")
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	
	Needle_Arm.disconnect("raycast_collided", self, "_on_jab_collision")
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(_delta):
	return


func _on_animation_finished(anim_name):
	if anim_name == "jab_test":
		reset_arm_rotation()
		emit_signal("state_switch", "none")


func aim_arm_transform(look_at_point):
	var jab_point : Vector3
	var look_vec : Vector3
	var interp_point : Vector3
	var interp_factor : float
	
	jab_point = look_at_point
	look_vec = Vector3(0,0,-1).rotated(Vector3(1,0,0), camera_angles.x)
	interp_point = Needle_Arm.to_global(look_vec)
	
	#Interpolation factor
	var radius = (jab_point - Body.get_global_transform().origin).length()
	
	if radius > aim_interp_radius_outer:
		interp_factor = 0
	elif radius < aim_interp_radius_inner:
		interp_factor = 1
	else:
		interp_factor = (aim_interp_radius_outer - radius) / (aim_interp_radius_outer - aim_interp_radius_inner)
	
	#Interpolation
	jab_point = jab_point.linear_interpolate(interp_point, interp_factor)
	
	Needle_Arm.look_at(jab_point, Vector3(0,1,0))
	
	#Debug
#	print(interp_factor)
#	Debug_Point.global_transform.origin = jab_point


func reset_arm_rotation():
	Needle_Arm.set_rotation(Vector3(0,0,0))


func _on_jab_collision(collision):
	if !has_hit:
		var collision_material = collision["col_material"]
		
		if collision_material in GlobalValues.collision_materials_solid:
			var velocity = add_recoil_velocity(collision)
			
			collision["recoil_vel"] = velocity
			
			emit_signal("jab_collision", collision)
		elif collision_material in GlobalValues.collision_materials_soft:
			Anim_Player.stop()
			
			attached_obj = collision["collider"]
			stick_point = attached_obj.to_local(collision["col_point"])
			
			emit_signal("jab_collision", collision)
			emit_signal("state_switch", "jab_stick")
	
	set_hit(true)


func add_recoil_velocity(collision):
	var recoil_velocity = Vector3(0,0,0)
	var recoil_vector = collision["col_normal"]
	var collision_type = collision["col_type"]
	
	if collision_type == "strong":
		recoil_velocity += recoil_vector * jab_strength
	elif collision_type == "weak":
		recoil_velocity += recoil_vector * jab_strength #should be weaker in the future
	else:
		print("invalid collision type sent to jab state")
		assert(1 == 2)
	
	return recoil_velocity


