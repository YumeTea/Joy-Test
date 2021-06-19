extends "res://Scripts/state_machine/state_machine.gd"


signal action_l_state_changed(action_state)
signal action_l_state_stack_changed(state_stack)

var initialized_values = {
	"camera_angles": Vector3(),
}

func _ready():
	states_map = {
		"none": $Shared/Action_L/None,
		"cast": $Shared/Action_L/Cast,
	#	"death": $Death,
	#	"void": $Void
	}
	#Send out dictionary of initialized values to all states at start
#	emit_signal("initialized_values_dic_set", initialized_values)
	
	emit_signal("action_l_state_changed", states_stack[0])
	emit_signal("action_l_state_stack_changed", states_stack)


func _change_state(state_name): #state_machine.gd does the generalized work
	if not _active:
		return
	
	#Store variables that are set to be initialized between states
	current_state.store_initialized_values(self.initialized_values)
	
	##Special State Handling
#	if state_name in ["void"]:
#		states_stack.clear()
#		states_stack.push_front(states_map[state_name])
	
	##States that stack
#	if state_name in []: #code for push automaton; "pushes" state_name onto top of state stack
#		states_stack.push_front(states_map[state_name])
	
	##State Change
	._change_state(state_name)
	
	emit_signal("action_l_state_changed", states_stack[0])
	emit_signal("action_l_state_stack_changed", states_stack)


func _input(_event): #only for handling input that can interrupt other states i.e. something that interrupts jumping
	return

