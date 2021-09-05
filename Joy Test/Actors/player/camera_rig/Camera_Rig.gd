extends Spatial


signal camera_angle_changed(camera_angles)
signal camera_raycast_collision_changed(collision_point)
signal state_machine_camera_state_stack_changed(state_stack)

#Camera Variables
var camera_angles : Vector3 #rotation of camera on all 3 axes
var look_at_point : Vector3

#Node Storage
onready var Pivot = get_node("Pivot")
onready var Camera_Controller = get_node("Pivot/Camera_Controller")
onready var Camera_Pos = get_node("Pivot/Camera_Controller/Camera_Pos")
onready var RayCast_Camera = get_node("Pivot/Camera_Controller/Camera_Pos/Camera/RayCast_Camera") #this raycast will be out of scene in future###


func _ready():
	#Add player as exception to camera raycast
	RayCast_Camera.add_exception(self.owner)


func _process(delta):
#	camera_obstruct_correct()
	update_camera_raycast()


'Maybe should use physics process??'
#Moves the camera's physics body from parent origin to intended position, checking for and stopping at collision
#with environment
func camera_obstruct_correct():
	var translate_center : Vector3
	
	translate_center = -Camera_Controller.get_translation()
	translate_center.z -= Pivot.get_translation().z #Prevent translation of camera to in front of player
	#Move camera_pos to pivot
	Camera_Pos.translation.z = translate_center.z
	
	#Move camera_pos back to controller and check for collision along the way
	var collision = null
	var move_test : Vector3
	
	move_test = Camera_Pos.to_global(-translate_center) - Camera_Pos.get_global_transform().origin
	
	collision = Camera_Pos.move_and_collide(move_test, true, true, true)
	
	if collision:
		var travel = collision.get_travel()
		travel = Camera_Pos.to_local(travel + Camera_Pos.get_global_transform().origin)
		
		if travel.z > 0.0:
			Camera_Pos.translation.z += travel.z
	else:
		Camera_Pos.translation.z = 0.0


func update_camera_raycast():
	RayCast_Camera.force_raycast_update()
	
	if RayCast_Camera.is_colliding():
		look_at_point = RayCast_Camera.get_collision_point()
	else:
		look_at_point = RayCast_Camera.to_global(RayCast_Camera.get_cast_to())
	
	emit_signal("camera_raycast_collision_changed", look_at_point)
	
	#Debug
#	$Debug_Look_At_Point.global_transform.origin = look_at_point


###SIGNAL FUNCTIONS###
func _on_Default_camera_angle_changed(camera_angles):
	emit_signal("camera_angle_changed", camera_angles)


func _on_Aim_camera_angle_changed(angles):
	emit_signal("camera_angle_changed", angles)


func _on_State_Machine_Camera_camera_state_stack_changed(state_stack):
	emit_signal("state_machine_camera_state_stack_changed", state_stack)
