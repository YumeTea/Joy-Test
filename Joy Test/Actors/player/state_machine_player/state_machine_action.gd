extends "res://Scripts/state_machine/state_machine.gd"


signal action_state_changed(action_state)
signal action_state_stack_changed(state_stack)
#signal initialized_values_dic_set(init_values_dic)

var initialized_values = {
	"camera_angle": Vector3(),
}

func _ready():
	states_map = {
		"none": $None,
		"jab": $Jab,
	#	"death": $Death,
	#	"void": $Void
	}
	#Send out dictionary of initialized values to all states at start
#	emit_signal("initialized_values_dic_set", initialized_values)
	
	emit_signal("action_state_changed", states_stack[0].name)
	emit_signal("action_state_stack_changed", states_stack)


func _change_state(state_name): #state_machine.gd does the generalized work
	if not _active:
		return
	
	##State variable initialization (all states are initialized)
	if !(state_name in ["previous"]):
		#Set initialized values in old state for transfer
		current_state.store_initialized_values(current_state.initialized_values)
		#Transfer initialized values to new state
		states_map[state_name].initialize_values(current_state.initialized_values) #initialize velocity for certain states out of walk state
	
	##Special State Handling
#	if state_name in ["void"]:
#		states_stack.clear()
#		states_stack.push_front(states_map[state_name])
	
	##States that stack
#	if state_name in []: #code for push automaton; "pushes" state_name onto top of state stack
#		states_stack.push_front(states_map[state_name])
	
	##Previous State initialization
	if state_name in ["previous"]:
		#Set initialized values in old state for transfer
		current_state.store_initialized_values(current_state.initialized_values)
		#Transfer initialized values to new state
		states_stack[1].initialize_values(current_state.initialized_values) #pass current state velocity to previous state if switching to previous state
	
	##State Change
	._change_state(state_name)
	
	#Send out dictionary of initialized values for states that don't initialize
#	emit_signal("initialized_values_dic_set", initialized_values)
	
	emit_signal("action_state_changed", states_stack[0].name)
	emit_signal("action_state_stack_changed", states_stack)


func _input(_event): #only for handling input that can interrupt other states i.e. something that interrupts jumping
	return

