extends "res://Actors/player/state_machine_player/shared/action_r/action_r.gd"


#Jab bools
var is_active : bool
var has_hit : bool

#Jab Variables
var jab_strength = 64

var arm_transform_default : Transform

#Node Storage
var Needle_Arm : Node


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	is_active = false
	has_hit = false
	
	Needle_Arm = owner.get_node("Body").get_node("Needle_Arm")
	
	arm_transform_default = Needle_Arm.get_transform()
	
	Needle_Arm.connect("raycast_collided", self, "_on_jab_collision")
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	reset_arm_transform(arm_transform_default)
	
	Needle_Arm.disconnect("raycast_collided", self, "_on_jab_collision")
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_released("aim_r") and !is_active:
		set_active(true)
		aim_arm_transform(camera_look_at_point)
		
		Anim_Player.play("jab_test")
	
	.handle_input(event)


#Acts as the _process method would
func update(_delta):
	return


func _on_animation_finished(anim_name):
	if anim_name == "jab_test":
		emit_signal("state_switch", "none")


func aim_arm_transform(look_at_point):
	Needle_Arm.look_at(look_at_point, Vector3(0,1,0))


func reset_arm_transform(transform):
	Needle_Arm.set_transform(transform)


func set_active(value):
	is_active = value


func _on_jab_collision(collision):
	if is_active and !has_hit:
		var velocity = add_recoil_velocity(collision["col_normal"])
		
		emit_signal("velocity_change", velocity)
		
		has_hit = true


func add_recoil_velocity(recoil_vector):
	var recoil_velocity = Vector3(0,0,0)
	
	recoil_velocity += recoil_vector * jab_strength
	
	return recoil_velocity


