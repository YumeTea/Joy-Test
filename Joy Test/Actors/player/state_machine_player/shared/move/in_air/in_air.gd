extends "res://Actors/player/state_machine_player/shared/move/motion.gd"

#In Air bools
var has_jumped : bool


#Initializes state, changes animation, etc
func enter():
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
	
	if owner.is_on_floor() and has_jumped:
		emit_signal("state_switch", "previous")


func _on_animation_finished(_anim_name):
	return

