extends "res://Actors/player/state_machine_player/shared/move/motion.gd"


#Initializes state, changes animation, etc
func enter():
	snap_vector = snap_vector_default
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	.update(delta)
	
	if !owner.is_on_floor():
		if !is_aiming:
			emit_signal("state_switch", "fall")
		elif is_aiming:
			emit_signal("state_switch", "fall_aim")


func _on_animation_finished(_anim_name):
	return

