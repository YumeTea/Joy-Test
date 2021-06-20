extends Spatial


onready var Pivot = owner.get_node("Pivot")


func _on_Camera_Rig_camera_angle_changed(camera_angles):
	var rot = Vector3(0,0,0)
	rot.y = rad2deg(camera_angles.y)
	
	self.set_rotation_degrees(rot)


