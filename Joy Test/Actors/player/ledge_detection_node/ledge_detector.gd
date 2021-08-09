extends Spatial

'Need to add roof raycast check'


signal ledge_detected(grab_data)


#Node Storage
onready var collider_shape = $Area/CollisionShape.shape
onready var RayCast_Ledge = $Area/RayCast_Ledge
onready var RayCast_Wall = $Area/RayCast_Wall

#Raycast Default Values
var raycast_ledge_trans_def : Vector3
var raycast_ledge_cast_to_def : Vector3
var raycast_wall_trans_def : Vector3
var raycast_wall_cast_to_def : Vector3

#Space Query Variables
var space_rid
var space_state
var query_shape
var intersections : Array #Array of all intersection points set by space_state query

#Ledge Detection Variables
const raycast_offset = 0.1
const ledge_backslope_angle_max = 45
const ledge_frontslope_angle_max = 10

#Ledge Variables
var grab_data = {
	"grab_obj": Node,
	"grab_point": Vector3(),
	"grab_dir": Vector3(),
	"ledge_move_dir": Vector3(),
}

#Ledge Flags
var on_ledge = false
var valid_ledge : bool

###DEBUG NODES###
onready var Debug_Point = get_node("Debug_Point")
onready var Debug_Point2 = get_node("Debug_Point2")
onready var Debug_Point3 = get_node("Debug_Point3")


func _ready():
	raycast_ledge_trans_def = RayCast_Ledge.translation
	raycast_ledge_cast_to_def = RayCast_Ledge.cast_to
	raycast_wall_trans_def = RayCast_Wall.translation
	raycast_wall_cast_to_def = RayCast_Wall.cast_to
	
	space_rid = get_world().space


func _process(delta):
	valid_ledge = false
	intersections = check_object_collisions()
	
	if intersections.size() > 0 and !on_ledge:
		var intersect_point = intersections[0]
		for i in intersections.size():
			if abs(intersections[i].z) <= abs(intersect_point.z) and abs(intersections[i].x) <= abs(intersect_point.x):
				intersect_point = intersections[i]
		
		#Adjust raycasts to check if collision is at a valid ledge
		#RayCast_Ledge
		var ray_xz_transform = Vector2(intersect_point.x, intersect_point.z).normalized() * (Vector2(intersect_point.x, intersect_point.z).length() + raycast_offset) 
		RayCast_Ledge.translation.x = ray_xz_transform.x
		RayCast_Ledge.translation.z = ray_xz_transform.y
		RayCast_Ledge.cast_to.y = -collider_shape.height
		#RayCast_Wall
		RayCast_Wall.translation.y = intersect_point.y - (collider_shape.height / 2.0) - raycast_offset #Needs to account fo collider height
		RayCast_Wall.cast_to.x = ray_xz_transform.x
		RayCast_Wall.cast_to.z = ray_xz_transform.y
		
		#Reposition raycasts for precision if they are colliding
		if RayCast_Ledge.is_colliding() and RayCast_Wall.is_colliding():
			RayCast_Ledge.force_raycast_update()
			RayCast_Wall.force_raycast_update()
			
			#Translate/update ledge raycast
			var translate_l = self.to_local(RayCast_Wall.get_collision_point())
			translate_l = translate_l.normalized() * (translate_l.length() + raycast_offset)
			RayCast_Ledge.translation.x = translate_l.x
			RayCast_Ledge.translation.z = translate_l.z
			RayCast_Ledge.force_raycast_update()
			
			#Translate/update wall raycast
			var translate_w = self.to_local(RayCast_Ledge.get_collision_point())
			RayCast_Wall.translation.y = translate_w.y - raycast_offset
			RayCast_Wall.force_raycast_update()
			
			#Check if raycast colliding surfaces constitute valid ledge
			check_valid_ledge()
	elif on_ledge:
		check_valid_ledge()
	
	if valid_ledge:
		#Calc ledge grab point for valid ledge
		calc_grab_data()
		emit_signal("ledge_detected", grab_data)
	else:
		grab_data["grab_obj"] = null
		grab_data["grab_point"] = null
		grab_data["grab_dir"] = null
		grab_data["ledge_up"] = null
		emit_signal("ledge_detected", grab_data)


func check_object_collisions():
	var intersections : Array
	
	#World Space RID
	space_rid = get_world().space
	
	#Get PhysicsDirectSpaceState
	space_state = PhysicsServer.space_get_direct_state(space_rid)
	
	#Create shape to query
	query_shape = PhysicsShapeQueryParameters.new()
	query_shape.transform = $Area/CollisionShape.global_transform #Query will be in units local to this transform
	query_shape.set_shape(collider_shape)
	query_shape.collision_mask = 0x40000 #Currently mask 01000 00000 00000 00000
	
	#Get intersection points on query shape
	intersections = space_state.collide_shape(query_shape, 32)
	
	return intersections


func check_valid_ledge():
	valid_ledge = false
	
	if RayCast_Ledge.is_colliding() and RayCast_Wall.is_colliding():
		var backdir = RayCast_Wall.get_collision_point() - RayCast_Ledge.get_collision_point()
		backdir.y = 0.0
		backdir = backdir.normalized()
		var backdotledge = -backdir.dot(RayCast_Ledge.get_collision_normal())
		var updotwall = Vector3(0,1,0).dot(RayCast_Wall.get_collision_normal())
		
		#Check ledge angle
		if backdotledge >= (1 - (deg2rad(90 + ledge_backslope_angle_max) / deg2rad(90))):
			if backdotledge <= (1 - (deg2rad(90 - ledge_frontslope_angle_max) / deg2rad(90))):
				#Check wall angle
				if updotwall <= 0.0 or is_equal_approx(updotwall, 0.0):
					valid_ledge = true


func calc_grab_data():
	var l1 : Vector3
	var l2 : Vector3
	var w1 : Vector3
	var w2 : Vector3
	var lambda_wall : float
	var mu_ledge : float
	
	var grab_point : Vector3
	var grab_dir : Vector3
	var ledge_move_dir : Vector3
	
	RayCast_Ledge.force_raycast_update()
	RayCast_Wall.force_raycast_update()
	
	#Get vector points for intersect calc
	l1 = RayCast_Ledge.get_collision_point()
	w1 = RayCast_Wall.get_collision_point()
	
	var rot_axis = (RayCast_Ledge.get_collision_normal().cross(RayCast_Wall.get_collision_normal())).normalized()
	l2 = l1 + RayCast_Ledge.get_collision_normal().rotated(rot_axis, PI/2)
	w2 = w1 + RayCast_Wall.get_collision_normal().rotated(rot_axis, -PI/2)
	
	#Use a non-zero endpoint to solve for mu_wall
	if w2.x != 0.0:
		if l2.y != 0.0:
			mu_ledge = ((w2.x * (l1.y - w1.y)) - (w2.y * (l1.x - w1.x))) / ((w2.y * l2.x) - (w2.x * l2.y))
		elif l2.z != 0.0:
			mu_ledge = ((w2.x * (l1.z - w1.z)) - (w2.z * (l1.x - w1.x))) / ((w2.z * l2.x) - (w2.x * l2.z))
	elif w2.y != 0.0:
		if l2.x != 0.0:
			mu_ledge = ((w2.y * (l1.x - w1.x)) - (w2.x * (l1.y - w1.y))) / ((w2.x * l2.y) - (w2.y * l2.x))
		elif l2.z != 0.0:
			mu_ledge = ((w2.y * (l1.z - w1.z)) - (w2.z * (l1.y - w1.y))) / ((w2.z * l2.y) - (w2.y * l2.z))
	elif w2.z != 0.0:
		if l2.x != 0.0:
			mu_ledge = ((w2.z * (l1.x - w1.x)) - (w2.x * (l1.z - w1.z))) / ((w2.x * l2.z) - (w2.z * l2.x))
		elif l2.y != 0.0:
			mu_ledge = ((w2.z * (l1.y - w1.y)) - (w2.y * (l1.z - w1.z))) / ((w2.y * l2.z) - (w2.z * l2.y))
		
	
	lambda_wall = (l1.x + (mu_ledge * l2.x) - w1.x) / w2.x
	
	
	#Calc grab point
	grab_point = Vector3()
	grab_point.x = w1.x + (lambda_wall * (w2.x - w1.x))
	grab_point.y = l1.y + (mu_ledge * (l2.y - l1.y))
	grab_point.z = w1.z + (lambda_wall * (w2.z - w1.z))
	
	#Calc grab direction
	grab_dir = Vector3()
	grab_dir = (l1 - l2)
	grab_dir.y = 0.0
	grab_dir = grab_dir.normalized()
	
	#Calc ledge up direction
	ledge_move_dir = (RayCast_Ledge.get_collision_normal().cross(RayCast_Wall.get_collision_normal())).normalized()
	
	#Set grab dict values
	grab_data["grab_obj"] = RayCast_Wall.get_collider()
	grab_data["grab_point"] = grab_point
	grab_data["grab_dir"] = grab_dir
	grab_data["ledge_move_dir"] = ledge_move_dir
	
	
	#DEBUG
	Debug_Point.global_transform.origin = w2
	Debug_Point2.global_transform.origin = l2
	Debug_Point3.global_transform.origin = grab_point


func _on_move_state_on_ledge(on_ledge_flag):
	on_ledge = on_ledge_flag
	
	if on_ledge:
		RayCast_Ledge.translation = raycast_ledge_trans_def
		RayCast_Ledge.cast_to = raycast_ledge_cast_to_def
		RayCast_Wall.translation = raycast_wall_trans_def
		RayCast_Wall.cast_to = raycast_wall_cast_to_def
		RayCast_Ledge.force_raycast_update()
		RayCast_Wall.force_raycast_update()
#	else:
#		grab_data["grab_obj"] = null
#		grab_data["grab_point"] = null
#		grab_data["grab_dir"] = null
#		grab_data["ledge_up"] = null
#		emit_signal("ledge_detected", grab_data)
