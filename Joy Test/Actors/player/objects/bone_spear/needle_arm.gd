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
		"col_type" : "",
		"col_normal": Vector3(),
	}
	#Calc collision length and get type of collision
	var col_length : float
	
	var origin_pt = raycast_node.get_global_transform().origin
	var col_pt = raycast_node.get_collision_point()
	
	col_length = origin_pt.distance_to(col_pt)
	
	var percent = col_length / cast_to_max
	
	if percent > weak_bound:
		collision["col_type"] = "weak"
	else:
		collision["col_type"] = "strong"
	
	#Calc collision normal
	var col_normal : Vector3
	
	col_normal = (origin_pt - col_pt).normalized() #Currently set collision normal in opposite direction of player
	
	collision["col_normal"] = col_normal
	
	return collision






