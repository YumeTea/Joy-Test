extends Spatial


signal camera_raycast_collision_changed(look_at_point)


var look_at_point : Vector3

#Node Storage
onready var RayCast_Camera = $Camera/RayCast_Camera


func _ready():
	###DEBUG?###
	Global.set_camera_main(self)


func _physics_process(delta):
	update_camera_raycast()


func update_camera_raycast():
	RayCast_Camera.force_raycast_update()
	
	if RayCast_Camera.is_colliding():
		look_at_point = RayCast_Camera.get_collision_point()
	else:
		look_at_point = RayCast_Camera.to_global(RayCast_Camera.get_cast_to())
	
	emit_signal("camera_raycast_collision_changed", look_at_point)
