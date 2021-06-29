extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"



func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	AnimStateMachineMotion.start("none") #TEMPORARY UNTIL FURTHER ANIMS ARE MADE
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if is_aiming:
		emit_signal("state_switch", "fall_aim")
		return
	
	.update(delta)


func _on_animation_finished(_anim_name):
	return




