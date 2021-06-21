extends "res://Actors/player/state_machine_player/shared/move/motion.gd"


#Initializes state, changes animation, etc
func enter():
	.exit()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	.update(delta)


func _on_animation_finished(_anim_name):
	return

