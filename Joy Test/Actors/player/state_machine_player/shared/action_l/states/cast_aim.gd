extends "res://Actors/player/state_machine_player/shared/action_l/action_l.gd"


#Aiming Variables
var aim_interp_radius_inner = 7
var aim_interp_radius_outer = 12

#Transform Storage
var arm_transform_default : Transform


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	if !is_charging:
		#Load spell assets if entering cast state
		charge_anim_scene = load(current_spell.charging_anim_scene)
		spell_projectile = load(current_spell.projectile_scene)
		
		#Spell charging initialization
		set_charging(true)
		set_casting(false)
		set_cast_ready(false)
		set_cast(false)
		start_charging_anim(current_spell)
	
	charging_spell_instance.get_node("AnimationPlayer").connect("animation_finished", self, "_on_animation_finished")
	
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	if charging_spell_instance != null:
		charging_spell_instance.get_node("AnimationPlayer").disconnect("animation_finished", self, "_on_animation_finished")
	
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)
	
	if Input.is_action_just_pressed("cancel") or !is_aiming:
		emit_signal("state_switch", "cast")
	
	#Cast charge input handling
	if !is_casting:
		if Input.is_action_just_released("attack_left"):
			if !cast_ready:
				reverse_charging_anim()
			else:
				start_cast_anim()
				set_casting(true)
		if Input.is_action_just_pressed("attack_left"):
			continue_charging_anim()


#Acts as the _process method would
func update(delta):
	if is_aiming == false:
		emit_signal("state_switch", "cast")
		return
	
	if cast:
		cast()
		set_cast(false)
	
	if is_casting:
		aim_arm_transform(camera_look_at_point)
		anchor_arm_l_transform()
	
	.update(delta)


func _on_animation_finished(anim_name):
	if anim_name == "charging":
		if is_charging:
			set_cast_ready(true) #reached end of animation
		else:
			cast_abort() #reached beginning of animation
	
	if anim_name == "cast":
		emit_signal("state_switch", "none")
	
	._on_animation_finished(anim_name)


func cast():
	end_charging_anim()
	set_charging(false)
	cast_projectile()


func cast_abort():
	end_charging_anim()
	set_charging(false)
	emit_signal("state_switch", "none")


func start_charging_anim(anim_scene):
	set_charging(true)
	
	var charge_anim_scene = load(current_spell.charging_anim_scene)
	var charge_anim = charge_anim_scene.instance()
	owner.get_node("Body/Armature/Skeleton/LeftHandBone/Spell_Origin").add_child(charge_anim)
	charging_spell_instance = owner.get_node("Body/Armature/Skeleton/LeftHandBone/Spell_Origin" + "/" + charge_anim.get_name())


func end_charging_anim():
	charging_spell_instance.get_node("AnimationPlayer").disconnect("animation_finished", self, "_on_animation_finished")
	charging_spell_instance.queue_free()


func reverse_charging_anim():
	charging_spell_instance.get_node("AnimationPlayer").play("charging", -1, -1.0, false)
	set_charging(false)


func continue_charging_anim():
	charging_spell_instance.get_node("AnimationPlayer").play("charging", -1, 1.0, false)
	set_charging(true)


func start_cast_anim():
	AnimTree.set("parameters/MotionActionLBlend/blend_amount", 0.99)
	AnimStateMachineActionL.travel("cast")


func cast_projectile():
	#Sets current projectile
	var projectile = spell_projectile.instance()
	#Sets facing angle to character model direction
	var facing_direction = Vector3(0,0,-1).rotated(Vector3(0,1,0), Body.get_rotation().y)
	
	#Initialize and spawn projectile
	var position_init = owner.get_node("Body/Armature/Skeleton/LeftHandBone/Spell_Origin").get_global_transform()
	var direction_init = position_init.origin.direction_to(camera_look_at_point)
	#Set projectile starting position, direction, and target. Add to scene tree
	projectile.start(position_init, direction_init)
	world.add_child(projectile) #Set projectile's parent as Projectiles node


func aim_arm_transform(look_at_point):
	var aim_point : Vector3
	var look_vec : Vector3
	var interp_point : Vector3
	var interp_factor : float
	
	var pose : Transform
	
	#Set arm custom pose back to default
	reset_custom_pose_arm_l()
	
	aim_point = look_at_point #This point is global
	#Get look direction vector and center it at aim controller point
	look_vec = Vector3(0,0,-1).rotated(Vector3(1,0,0), camera_angles.x)
	interp_point = LeftArmController.to_global(look_vec)
	
	#Interpolation factor for aim point
	var radius = (aim_point - Body.get_global_transform().origin).length()
	
	if radius > aim_interp_radius_outer:
		interp_factor = 0
	elif radius < aim_interp_radius_inner:
		interp_factor = 1
	else:
		interp_factor = (aim_interp_radius_outer - radius) / (aim_interp_radius_outer - aim_interp_radius_inner)
	
	#Aim Point Interpolation
	aim_point = aim_point.linear_interpolate(interp_point, interp_factor)
	
	#Create custom pose
	pose.origin = LeftArmController.get_global_transform().origin
	pose.basis = Basis(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1))
	
	pose = pose.looking_at(aim_point, Vector3(0,1,0))
	
	pose.origin = Vector3(0,0,0)
	pose = pose.rotated(Vector3(0,1,0), -Body.get_rotation().y)
	
	Skel.set_bone_custom_pose(LeftArmController_idx, pose)


