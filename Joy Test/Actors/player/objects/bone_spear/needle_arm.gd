extends Spatial

signal raycast_collided()

#Raycast variables
var cast_to_max = 55
var weak_bound = 0.75 #percent of max jab length past which a hit is weak

onready var Raycast = self.get_node("RayCast")


func _process(delta):
	if Raycast.is_colliding():
#		Raycast.force_raycast_update() #Player has moved already, but raycast has not updated
		var collision = get_collision_values(Raycast)
		emit_signal("raycast_collided", collision)


func get_collision_values(raycast_node):
	var collision = {
		"collider": Node,
		"col_material" : "",
		"col_type" : "",
		"col_point" : Vector3(),
		"col_normal": Vector3(),
		"recoil_vel": Vector3(),
	}
	
	###COLLIDER
	collision["collider"] = raycast_node.get_collider()
	
	###COL_MATERIAL
	collision["col_material"] = get_collision_material(raycast_node)
	
	###COL_TYPE
	collision["col_type"] = get_collision_type(raycast_node)
	
	###COL_POINT
	collision["col_point"] = raycast_node.get_collision_point()
	
	###COL_NORMAL
	collision["col_normal"] = get_collision_normal(raycast_node)
	
	###RECOIL_VEL
	collision["recoil_vel"] = Vector3(0,0,0) #this is set by receivers
	
	return collision


func get_collision_material(raycast_node):
	var collision_object : Node
	var collision_material : String
	
	collision_object = raycast_node.get_collider()
	
	for group in collision_object.get_groups():
		if group in GlobalValues.collision_material_groups:
			collision_material = group
		else:
			collision_material = "none"
	
	return collision_material


func get_collision_type(raycast_node):
	var col_type : String
	var col_length : float
	
	var origin_pt = raycast_node.get_global_transform().origin
	var col_pt = raycast_node.get_collision_point()
	
	col_length = origin_pt.distance_to(col_pt)
	
	var percent = col_length / cast_to_max
	
	if percent > weak_bound:
		col_type = "weak"
	else:
		col_type  = "strong"
	
	return col_type


func get_collision_normal(raycast_node):
	var col_normal : Vector3
	
	var origin_pt = raycast_node.get_global_transform().origin
	var col_pt = raycast_node.get_collision_point()
	
	col_normal = (origin_pt - col_pt).normalized() #Currently set collision normal in opposite direction of player
	
	return col_normal



