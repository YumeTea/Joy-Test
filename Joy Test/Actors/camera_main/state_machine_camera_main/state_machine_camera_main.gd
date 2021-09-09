extends "res://Scripts/state_machine/state_machine.gd"


signal camera_main_state_changed(camera_state)
signal camera_main_state_stack_changed(state_stack)


var initialized_values = {
	###SHARED
}


func _ready():
	states_map = { #populate state map on initialization
		"player_follow": $Shared/Player_Follow
	}
	
	stack_states = [
	]
	
	emit_signal("camera_main_state_changed", states_stack[0].name)
	emit_signal("camera_main_state_stack_changed", states_stack)


func _change_state(state_name): #state_machine.gd does the generalized work
	if not _active:
		return
	
	##Special new state handling
#	if state_name in ["swim"] and current_state in [$Jump, $Fall]:
#		states_stack.pop_front()
		
	##Stack states that stack
	if state_name in stack_states: #code for push automaton; "pushes" state_name onto top of state stack
		states_stack.push_front(states_map[state_name])
	
	##State Change
	._change_state(state_name)
	
	emit_signal("camera_main_state_changed", states_stack[0].name)
	emit_signal("camera_main_state_stack_changed", states_stack)


func _input(_event): #only for handling input that can interrupt other states i.e. something that interrupts jumping
	return


