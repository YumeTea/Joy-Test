extends "res://Actors/player/state_machine_player/shared/action_l/action_l.gd"


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	connect_local_signals()


#Cleans up state, reinitializes values like timers
func exit():
	disconnect_local_signals()


#Creates output based on the input event passed in
func handle_input(_event):
	if Input.is_action_just_pressed("attack_left"):
		emit_signal("state_switch", "cast")


#Acts as the _process method would
func update(_delta):
	return


func _on_animation_finished(_anim_name):
	return

