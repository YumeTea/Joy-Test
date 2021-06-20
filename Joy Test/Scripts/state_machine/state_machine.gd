extends Node


export(NodePath) var START_STATE #export makes variable part of scene it is called in and editable in the editor
var states_map = {} #stores all possible state nodes

var states_stack = [] #stores current states for push automaton
var stack_states = [] #reference for what states stack
var current_state = null
var _active = false setget set_active


func _ready():
	connect_state_signals()
	initialize(START_STATE)


#Finds the lowest tier nodes of the state machine and connects to their state switch signals
func connect_state_signals():
	for child in get_children():
		if child is Node and !(child is Timer):
			if child.get_children().size() == 0:
				child.connect("state_switch", self, "_change_state")
			else:
				for child_lower in child.get_children():
					if child_lower is Node:
						if child_lower.get_children().size() == 0:
							child_lower.connect("state_switch", self, "_change_state")
						else:
							for child_lower_2 in child_lower.get_children():
								if child_lower_2 is Node:
									if child_lower_2.get_children().size() == 0:
										child_lower_2.connect("state_switch", self, "_change_state")
									else:
										for child_lower_3 in child_lower_2.get_children():
											if child_lower_3 is Node:
												if child_lower_3.get_children().size() == 0:
													child_lower_3.connect("state_switch", self, "_change_state")


#Called in ready, state_machine is only active if called by a script
func initialize(start_state):
	set_active(true)
	states_stack.push_front(get_node(start_state))
	current_state = states_stack[0]
	current_state.enter()


#Sets state machine active in initialize method
func set_active(value):
	_active = value
	set_physics_process(value)
	set_process_input(value)
	if not _active:
		states_stack = []
		current_state = null


func _input(event):
	current_state.handle_input(event)


func _physics_process(delta):
	current_state.update(delta)


func _on_animation_finished(anim_name):
	if not _active:
		return
	current_state._on_animation_finished(anim_name)


func _change_state(state_name): #changes state, with handling for replacing, stacking, and various manipulation of state stack
	if not _active:
		return
	current_state.exit() #runs exit method for current state to adjust values before following states
	
	current_state.store_initialized_values(self.initialized_values)
	
	if state_name == "previous": #code for push automaton; pops state off top of stack if necessary
		states_stack.pop_front()
	else: #change state to state_name otherwise
		states_stack[0] = states_map[state_name] #place new state at top of state stack array
	
	current_state = states_stack[0]
	
	#Transfer initialized variables(should be stored earlier in child script)
	current_state.initialize_values(self.initialized_values)
	
	#New State Initialization
	current_state.enter() #always reinitialize a new state

