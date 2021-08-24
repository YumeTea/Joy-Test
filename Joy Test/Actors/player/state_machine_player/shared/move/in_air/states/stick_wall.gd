extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"


#Player attachment variables
var attached_arm_pos : Vector3

#Node Storage
onready var RightArmController = owner.get_node("Body/Armature/Skeleton/RightArmController")


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	velocity = Vector3(0,0,0)
	#Zero out fasten velocity in states where player is not fastened
	velocity_fasten = Vector3(0,0,0)
	attached_arm_pos = attached_obj.to_local(RightArmController.get_global_transform().origin)
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("jump"):
		emit_signal("state_switch", "stick_jump")
		return
	elif Input.is_action_just_pressed("attack_right"):
		exit_stick_state()
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	velocity = calc_stick_velocity(delta)
	
	#Counteract gravity
	velocity.y -= (gravity * weight * delta)
	
	.update(delta)
	
	if owner.get_slide_count() > 0:
		exit_stick_state()


func _on_animation_finished(_anim_name):
	return


func calc_stick_velocity(delta):
	var arm_pos_current : Vector3 #position relative to attached object origin
	var arm_pos_next : Vector3
	var velocity : Vector3
	
	arm_pos_current = RightArmController.get_global_transform().origin
	arm_pos_next = attached_obj.to_global(attached_arm_pos - attached_obj.translation)
	
	velocity = (arm_pos_next - arm_pos_current) / delta
	
	return velocity


func exit_stick_state():
	emit_signal("state_switch", "fall")
	return

