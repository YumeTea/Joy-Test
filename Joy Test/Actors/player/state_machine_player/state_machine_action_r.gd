extends "res://Scripts/state_machine/state_machine.gd"


signal action_r_state_changed(action_state)
signal action_r_state_stack_changed(state_stack)

var initialized_values = {
	###SHARED
	"camera_angles": Vector3(),
	"camera_look_at_point": Vector3(),
	
	"attached_obj": Node,
	
	###ACTION R SPECIFIC
	#Jab Variables
	"stick_point": Vector3(),
	"attached_facing_dir": Vector3(),
	
	#Anim Variables
	"anim_pause_position": 0.0,
	
	#Shared Flags
	"arm_r_occupied": false,
	"can_aim": true,
	"is_aiming": false,
	
	#ActionR Flags
	"hit_active": false,
}

func _ready():
	states_map = {
		"none": $Shared/Action_R/None,
		"jab": $Shared/Action_R/Jab,
		"jab_stick": $Shared/Action_R/Jab_Stick,
		"jab_stick_jump": $Shared/Action_R/Jab_Stick_Jump,
		
		"occupied_r": $Shared/Action_R/Occupied_R,
	#	"death": $Death,
	#	"void": $Void
	}
	
	emit_signal("action_r_state_changed", states_stack[0])
	emit_signal("action_r_state_stack_changed", states_stack)


func _change_state(state_name): #state_machine.gd does the generalized work
	if not _active:
		return
	
	##Special State Handling
#	if state_name in ["void"]:
#		states_stack.clear()
#		states_stack.push_front(states_map[state_name])
	
	##States that stack
#	if state_name in []: #code for push automaton; "pushes" state_name onto top of state stack
#		states_stack.push_front(states_map[state_name])
	
	##State Change
	._change_state(state_name)
	
	emit_signal("action_r_state_changed", states_stack[0])
	emit_signal("action_r_state_stack_changed", states_stack)


func _input(_event): #only for handling input that can interrupt other states i.e. something that interrupts jumping
	return

