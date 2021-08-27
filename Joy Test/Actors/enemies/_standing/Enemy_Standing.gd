extends KinematicBody


signal velocity_changed(velocity)
signal position_changed(position)


func _ready():
	connect_motion_signals()


func connect_motion_signals():
	var motion_state = $State_Machines/State_Machine_Move/Shared/Motion
	
	for area_state in motion_state.get_children():
		for move_state in area_state.get_children():
			move_state.connect("velocity_changed", self, "_on_velocity_changed")
	for area_state in motion_state.get_children():
		for move_state in area_state.get_children():
			move_state.connect("position_changed", self, "_on_position_changed")


func _on_velocity_changed(velocity):
	emit_signal("velocity_changed", velocity)


func _on_position_changed(position):
	emit_signal("position_changed", position)
