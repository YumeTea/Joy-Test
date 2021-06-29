extends "res://Actors/player/state_machine_player/shared/move/motion.gd"

#In Air bools
var has_jumped = true


#Initializes state, changes animation, etc
func enter():
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
	
	if owner.is_on_floor() and has_jumped: #check has_jumped to allow jump squat to play out
		if !is_aiming:
			emit_signal("state_switch", "idle")
		elif is_aiming:
			emit_signal("state_switch", "idle_aim")


func _on_animation_finished(_anim_name):
	return


func set_jumped(value):
	has_jumped = value

