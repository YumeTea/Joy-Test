extends "res://Actors/player/state_machine_player/shared/action_l/action_l.gd"


var anim_instance : Node

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
	
	start_casting_anim(current_spell_anim)
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	reset_arm_transform(arm_transform_default)
	
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	aim_arm_transform(camera_look_at_point)
	
	.update(delta)


func _on_animation_finished(anim_name):
	if anim_name == "Cast_Life_Buster":
		end_casting_anim()
		cast_projectile()
		reset_arm_transform(arm_transform_default)
		emit_signal("state_switch", "none")
		


func start_casting_anim(anim_scene):
	var anim = anim_scene.instance()
	owner.get_node("Body/Spell_Arm/Projectile_Pos").add_child(anim)
	anim_instance = owner.get_node("Body/Spell_Arm/Projectile_Pos" + "/" + anim.get_name())
	
	#Connect to animation player
	anim_instance.get_node("AnimationPlayer").connect("animation_finished", self, "_on_animation_finished")


func end_casting_anim():
	anim_instance.get_node("AnimationPlayer").disconnect("animation_finished", self, "_on_animation_finished")
	anim_instance.queue_free()


func cast_projectile():
	#Sets current projectile
	var projectile_current = current_spell #determined by ??? in future
	var projectile = projectile_current.instance()
	#Sets facing angle to character model direction
	var facing_direction = Vector3(0,0,-1).rotated(Vector3(0,1,0), deg2rad(Body.get_rotation_degrees().y))
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


