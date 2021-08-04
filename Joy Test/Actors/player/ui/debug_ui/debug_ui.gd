extends Control


signal state_machine_move_stack_changed(state_stack)
signal state_machine_action_l_stack_changed(state_stack)
signal state_machine_action_r_stack_changed(state_stack)
signal state_machine_camera_stack_changed(state_stack)
signal player_velocity_changed(velocity)
signal player_height_changed(height)


func _ready():
	owner.get_node("State_Machines/State_Machine_Move/Shared/Motion").connect("velocity_changed", self, "_on_Motion_velocity_changed")


func _on_State_Machine_Move_move_state_stack_changed(state_stack):
	emit_signal("state_machine_move_stack_changed", state_stack)


func _on_State_Machine_Action_L_action_l_state_stack_changed(state_stack):
	emit_signal("state_machine_action_l_stack_changed", state_stack)


func _on_State_Machine_Action_R_action_r_state_stack_changed(state_stack):
	emit_signal("state_machine_action_r_stack_changed", state_stack)


func _on_Camera_Rig_state_machine_camera_state_stack_changed(state_stack):
	emit_signal("state_machine_camera_stack_changed", state_stack)


func _on_Player_velocity_changed(velocity):
	emit_signal("player_velocity_changed", velocity)


func _on_Player_height_changed(height):
	emit_signal("player_height_changed", height)

