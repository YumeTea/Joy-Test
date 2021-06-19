extends "res://Actors/player/state_machine_player/shared/action_r/action_r.gd"

#Jab Variables
var jab_strength = 64

#Node Storage
var needle_arm_node : Node


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	needle_arm_node = owner.get_node("Body").get_node("Needle_Arm")
	needle_arm_node.connect("raycast_collided", self, "_on_jab_collision")
	connect_local_signals()
	Anim_Player.play("jab_test")


#Cleans up state, reinitializes values like timers
func exit():
	needle_arm_node.disconnect("raycast_collided", self, "_on_jab_collision")
	disconnect_local_signals()


#Creates output based on the input event passed in
func handle_input(_event):
	return


#Acts as the _process method would
func update(_delta):
	return


func _on_animation_finished(anim_name):
	if anim_name == "jab_test":
		emit_signal("state_switch", "none")


func _on_jab_collision(collision):
	var velocity = add_recoil_velocity(collision["col_normal"])
	
	emit_signal("velocity_change", velocity)
	
#	owner.move_and_slide_with_snap(velocity, Vector3(0,0,0), Vector3(0, 1, 0), true, 4, deg2rad(50))
	


func add_recoil_velocity(recoil_vector):
	var recoil_velocity = Vector3(0,0,0)
	
	recoil_velocity += recoil_vector * jab_strength
	
	return recoil_velocity


