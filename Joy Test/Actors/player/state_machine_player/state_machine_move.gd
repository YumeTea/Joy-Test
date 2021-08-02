extends "res://Scripts/state_machine/state_machine.gd"


signal move_state_changed(move_state)
signal move_state_stack_changed(state_stack)


var initialized_values = {
	###SHARED
	#Shared Nodes
	"attached_obj": Node,
	
	#Motion Variables
	"grab_point": Vector3(),
	"grab_dir": Vector3(),
	
	#Motion Flags
	"stop_on_slope": true,
	"can_wall_jump": false,
	"can_ledge_grab": true,
	
	#Shared Flags
	"arm_l_occupied": false,
	"arm_r_occupied": false,
	"can_aim": true,
	"is_aiming": false,
	"is_b_sliding": false,
	
	#Motion
	"velocity": Vector3(),
	"wall_col": Vector3(),
	"camera_angles": Vector3(),
	"camera_look_at_point": Vector3(),
	
	
}


func _ready():
	states_map = { #populate state map on initialization
		#On Ground
		"idle": $Shared/Motion/On_Ground/Idle,
		"walk": $Shared/Motion/On_Ground/Walk,
		"barrier_slide": $Shared/Motion/On_Ground/Barrier_Slide,
		
		#In Air
		"jump": $Shared/Motion/In_Air/Jump,
		"fall": $Shared/Motion/In_Air/Fall,
		"wall_jump": $Shared/Motion/In_Air/Wall_Jump,
		"stick_wall": $Shared/Motion/In_Air/Stick_Wall,
		"stick_jump": $Shared/Motion/In_Air/Stick_Jump,
		"ledge_hang": $Shared/Motion/In_Air/Ledge_Hang,
		
	#	"death": $Death,
	#	"void": $Void
	}
	
	stack_states = [
	]
	
	emit_signal("move_state_changed", states_stack[0].name)
	emit_signal("move_state_stack_changed", states_stack)


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
	
	emit_signal("move_state_changed", states_stack[0].name)
	emit_signal("move_state_stack_changed", states_stack)


func _input(_event): #only for handling input that can interrupt other states i.e. something that interrupts jumping
	return


