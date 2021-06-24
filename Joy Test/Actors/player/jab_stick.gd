extends "res://Actors/player/state_machine_player/shared/action_r/action_r.gd"


#Node Storage
var Needle_Arm : Node


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	Needle_Arm = owner.get_node("Body").get_node("Needle_Arm")
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("attack_right"):
		continue_jab_anim()
		
	
	.handle_input(event)


#Acts as the _process method would
func update(_delta):
	if owner.get_slide_count() > 0:
		continue_jab_anim()


func _on_animation_finished(anim_name):
	if anim_name == "jab_test":
		reset_arm_rotation()
		emit_signal("state_switch", "none")


func continue_jab_anim():
	Anim_Player.play()


func reset_arm_rotation():
	Needle_Arm.set_rotation_degrees(Vector3(0,0,0))
