extends Label


var camera_state_stack : Array


func update_display():
	self.text = ""
	for state_idx in camera_state_stack.size():
		self.text += "%s" % camera_state_stack[state_idx].get_name() + "\n"


func _on_Debug_UI_state_machine_camera_stack_changed(state_stack):
	camera_state_stack = state_stack
	update_display() #only update display when state stack changes

