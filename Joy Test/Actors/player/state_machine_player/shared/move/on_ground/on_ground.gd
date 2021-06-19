extends "res://Actors/player/state_machine_player/shared/move/motion.gd"


#Initializes state, changes animation, etc
func enter():
	snap_vector = snap_vector_default
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	return


#Creates output based on the input event passed in
func handle_input(_event):
	return


#Acts as the _process method would
func update(delta):
	.update(delta)


func _on_animation_finished(_anim_name):
	return

