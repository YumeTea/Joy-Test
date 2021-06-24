extends Spatial


signal camera_angle_changed(camera_angles)
signal camera_raycast_collision_changed(collision_point)
signal state_machine_camera_state_stack_changed(state_stack)


var look_at_point : Vector3

#Node Storage
onready var RayCast_Camera = get_node("Pivot/Camera_Pos/Camera/RayCast_Camera")


func _ready():
	#Add player as exception to camera raycast
	RayCast_Camera.add_exception(self.owner)


func _process(delta):
	update_camera_raycast()


func update_camera_raycast():
	RayCast_Camera.force_raycast_update()
	
	if RayCast_Camera.is_colliding():
		look_at_point = RayCast_Camera.get_collision_point()
	else:
		look_at_point = RayCast_Camera.to_global(RayCast_Camera.get_cast_to())
	
	emit_signal("camera_raycast_collision_changed", look_at_point)
	
	$Debug_Look_At_Point.global_transform.origin = look_at_point


###SIGNAL FUNCTIONS###
func _on_Default_camera_angle_changed(camera_angles):
	emit_signal("camera_angle_changed", camera_angles)


func _on_Aim_camera_angle_changed(camera_angles):
	emit_signal("camera_angle_changed", camera_angles)


func _on_State_Machine_Camera_camera_state_stack_changed(state_stack):
	emit_signal("state_machine_camera_state_stack_changed", state_stack)
