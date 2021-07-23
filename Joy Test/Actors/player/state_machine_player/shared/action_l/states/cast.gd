extends "res://Actors/player/state_machine_player/shared/action_l/action_l.gd"


'cast anim controller bone disconnects when running'


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
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("aim_r"):
		emit_signal("state_switch", "cast_aim")
	
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
	
	.handle_input(event)


#Acts as the _process method would
func update(_delta):
	if cast:
		cast()
		set_cast(false)
	
	if is_casting:
		anchor_arm_l_transform()


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


func start_charging_anim(spell_resource):
	set_charging(true)
	
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
	AnimTree.set("parameters/MotionActionLBlend/blend_amount", 1.0)
	AnimStateMachineActionL.travel("cast")


func cast_projectile():
	var projectile = spell_projectile.instance()
	#Sets facing angle to character model direction
	var facing_direction = Vector3(0,0,-1).rotated(Vector3(0,1,0), Body.get_rotation().y)
	
	#Initialize and spawn projectile
	var position_init = owner.get_node("Body/Armature/Skeleton/LeftHandBone/Spell_Origin").get_global_transform()
	var direction_init = facing_direction
	#Set projectile starting position, direction, and target. Add to scene tree
	projectile.start(position_init, direction_init)
	world.add_child(projectile) #Set projectile's parent as Projectiles node





