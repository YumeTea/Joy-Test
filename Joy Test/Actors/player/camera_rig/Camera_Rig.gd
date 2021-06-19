extends Spatial


signal camera_angle_changed(camera_angles)








###SIGNAL FUNCTIONS###
func _on_Default_camera_angle_changed(camera_angles):
	emit_signal("camera_angle_changed", camera_angles)


func _on_Aim_camera_angle_changed(camera_angles):
	emit_signal("camera_angle_changed", camera_angles)

