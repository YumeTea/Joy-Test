extends "res://Actors/player/state_machine_player/states/shared/shared.gd"


#Initialized values storage
var initialized_values : Dictionary


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


#Stores certain values of the current state to be transferred to the next state
#Called from main state machine
func store_initialized_values(init_values_dic):
	for value in init_values_dic:
		init_values_dic[value] = self[value]


func connect_player_signals():
	owner.get_node("AnimationPlayer").connect("animation_finished", self, "_on_animation_finished")


func disconnect_player_signals():
	owner.get_node("AnimationPlayer").disconnect("animation_finished", self, "_on_animation_finished")

