extends "res://Actors/player/state_machine_player/shared/action_l/action_l.gd"


var life_buster_anim_scene = preload("res://Actors/player/objects/life_buster/anim/Life_Buster_Anim.tscn")
var current_spell_anim = life_buster_anim_scene

var life_buster_scene = preload("res://Actors/player/objects/life_buster/life_buster.tscn")
var current_spell = life_buster_scene


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	if !is_casting:
		set_casting(true)
		set_cast_ready(false)
		start_casting_anim(current_spell_anim)
	
	anim_current_instance.get_node("AnimationPlayer").connect("animation_finished", self, "_on_animation_finished")
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	anim_current_instance.get_node("AnimationPlayer").disconnect("animation_finished", self, "_on_animation_finished")
	
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("aim_r"):
		emit_signal("state_switch", "cast_aim")
	
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
func update(_delta):
	return


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
	var facing_direction = Vector3(0,0,-1).rotated(Vector3(0,1,0), deg2rad(Body.get_rotation_degrees().y))
#	var camera_direction = Vector3(0,0,-1).rotated(Vector3(0,1,0), camera_angles.y)
	
	#Initialize and spawn projectile
	var position_init = owner.get_node("Body/Spell_Arm/Projectile_Pos").get_global_transform()
	var direction_init = facing_direction
	#Set projectile starting position, direction, and target. Add to scene tree
	projectile.start(position_init, direction_init)
	world.add_child(projectile) #Set projectile's parent as Projectiles node






