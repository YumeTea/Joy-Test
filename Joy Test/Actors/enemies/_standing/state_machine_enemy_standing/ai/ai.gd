extends "res://Scripts/state_machine/state_default.gd"


signal move_dir_changed(move_dir)


#Initializes state, changes animation, etc
func enter():
	return


#Cleans up state, reinitializes values like timers
func exit():
	return


#Creates output based on the input event passed in
func handle_input(_event):
	return


#Acts as the _process method would
func update(_delta):
	return


func _on_animation_finished(_anim_name):
	return
