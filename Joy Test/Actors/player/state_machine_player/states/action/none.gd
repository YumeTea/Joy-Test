extends "res://Actors/player/state_machine_player/states/action/action.gd"


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	connect_player_signals()


#Cleans up state, reinitializes values like timers
func exit():
	disconnect_player_signals()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("attack_right"):
		emit_signal("state_switch", "jab")


#Acts as the _process method would
func update(_delta):
	return


func _on_animation_finished(_anim_name):
	return

