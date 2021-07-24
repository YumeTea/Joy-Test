extends "res://Actors/player/state_machine_player/shared/action_l/action_l.gd"


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
#	if Input.is_action_just_pressed("aim_r"):
#		emit_signal("state_switch", "barrier_aim")
	
	
	.handle_input(event)


#Acts as the _process method would
func update(_delta):
	pass


func _on_animation_finished(anim_name):
	._on_animation_finished(anim_name)
