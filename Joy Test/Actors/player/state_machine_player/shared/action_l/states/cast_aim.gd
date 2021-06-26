extends "res://Actors/player/state_machine_player/shared/action_l/action_l.gd"


var life_buster_anim_scene = preload("res://Actors/player/objects/life_buster/anim/Life_Buster_Anim.tscn")
var current_spell_anim = life_buster_anim_scene

var life_buster_scene = preload("res://Actors/player/objects/life_buster/life_buster.tscn")
var current_spell = life_buster_scene

#Transform Storage
var arm_transform_default : Transform

#Node Storage
var Spell_Arm : Node


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	set_aiming(true)
	
	Spell_Arm = owner.get_node("Body").get_node("Spell_Arm")
	
	arm_transform_default = Spell_Arm.get_transform()
	
	if !is_casting:
		set_casting(true)
		set_cast_ready(false)
		start_casting_anim(current_spell_anim)
	
	anim_current_instance.get_node("AnimationPlayer").connect("animation_finished", self, "_on_animation_finished")
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	anim_current_instance.get_node("AnimationPlayer").disconnect("animation_finished", self, "_on_animation_finished")
	
	reset_arm_transform(arm_transform_default)
	
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("cancel") or !is_aiming:
		emit_signal("state_switch", "cast")
	
	#Cast charge input handling
	if Input.is_action_just_released("attack_left"):
		if !cast_ready:
			reverse_casting_anim()
		else:
			cast()
	if Input.is_action_just_pressed("attack_left"):
		continue_casting_anim()
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if is_aiming == false:
		emit_signal("state_switch", "cast")
		return
	
	aim_arm_transform(camera_look_at_point)
	
	.update(delta)


func _on_animation_finished(anim_name):
	if anim_name == "Casting":
		if is_charging:
			set_cast_ready(true) #reached end of animation
		else:
			cast_abort() #reached beginning of animation


func cast():
	end_casting_anim()
	cast_projectile()
	set_casting(false)
	set_charging(false)
	emit_signal("state_switch", "none")


func cast_abort():
	end_casting_anim()
	set_casting(false)
	set_charging(false)
	emit_signal("state_switch", "none")


func start_casting_anim(anim_scene):
	set_charging(true)
	
	var anim = anim_scene.instance()
	owner.get_node("Body/Spell_Arm/Projectile_Pos").add_child(anim)
	anim_current_instance = owner.get_node("Body/Spell_Arm/Projectile_Pos" + "/" + anim.get_name())


func end_casting_anim():
	anim_current_instance.queue_free()


func reverse_casting_anim():
	anim_current_instance.get_node("AnimationPlayer").play("Casting", -1, -1.0, false)
	set_charging(false)


func continue_casting_anim():
	anim_current_instance.get_node("AnimationPlayer").play("Casting", -1, 1.0, false)
	set_charging(true)


func cast_projectile():
	#Sets current projectile
	var projectile_current = current_spell #determined by ??? in future
	var projectile = projectile_current.instance()
	#Sets facing angle to character model direction
	var facing_direction = Vector3(0,0,-1).rotated(Vector3(0,1,0), Body.get_rotation().y)
#	var camera_direction = Vector3(0,0,-1).rotated(Vector3(0,1,0), camera_angles.y)
	
	#Initialize and spawn projectile
	var position_init = owner.get_node("Body/Spell_Arm/Projectile_Pos").get_global_transform()
	var direction_init = position_init.origin.direction_to(camera_look_at_point)
	#Set projectile starting position, direction, and target. Add to scene tree
	projectile.start(position_init, direction_init)
	world.add_child(projectile) #Set projectile's parent as Projectiles node


func aim_arm_transform(look_at_point):
	Spell_Arm.look_at(look_at_point, Vector3(0,1,0))


func reset_arm_transform(transform):
	Spell_Arm.set_transform(transform)


