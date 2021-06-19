extends Control


signal state_machine_move_stack_changed(state_stack)
signal state_machine_action_l_stack_changed(state_stack)
signal state_machine_action_r_stack_changed(state_stack)


func _on_State_Machine_Move_move_state_stack_changed(state_stack):
	emit_signal("state_machine_move_stack_changed", state_stack)


func _on_State_Machine_Action_L_action_l_state_stack_changed(state_stack):
	emit_signal("state_machine_action_l_stack_changed", state_stack)


func _on_State_Machine_Action_R_action_r_state_stack_changed(state_stack):
	emit_signal("state_machine_action_r_stack_changed", state_stack)











