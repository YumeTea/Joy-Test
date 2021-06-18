extends "res://Actors/player/state_machine_player/states/action/action.gd"


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	connect_player_signals()
	Anim_Player.play("jab_test")


#Cleans up state, reinitializes values like timers
func exit():
	disconnect_player_signals()


#Creates output based on the input event passed in
func handle_input(_event):
	return


#Acts as the _process method would
func update(_delta):
	return


func _on_animation_finished(anim_name):
	if anim_name == "jab_test":
		emit_signal("state_switch", "none")


