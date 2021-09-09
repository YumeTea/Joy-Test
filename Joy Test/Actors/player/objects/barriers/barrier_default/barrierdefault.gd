extends StaticBody


#Barrier Values
const barrier_radius = 3.38

#Deflection Values
var deflection = {
	"direction": Vector3(),
	"velocity": Vector3(),
	"axis": Vector3(),
	"angle": 0.0,
}

#rotation axis is cross of travel v and collision normal(vector from sphere center to collision point)


func deflect_projectile(col_projectile : KinematicCollision):
	var angle : float
	var axis : Vector3
	var start_pt : Vector3
	var end_pt : Vector3
	var dir_deflection : Vector3
	var vel_deflection : Vector3
	
	var vel_remainder : Vector3
	if col_projectile.remainder != Vector3(0,0,0):
		vel_remainder = col_projectile.remainder
		
		#Calc angle to rotate around barrier
		angle = calc_rot_angle(vel_remainder)
		
		#Calc rotation axis
		var normal_surface = (col_projectile.position - self.get_global_transform().origin).normalized()
		var dir_barrier = (self.to_global(Vector3(0,0,-1)) - self.get_global_transform().origin).normalized()
		axis = dir_barrier.cross(normal_surface).normalized()
		
		#Calc vector from collision point to next point
		start_pt = col_projectile.position
		end_pt = (col_projectile.position - self.get_global_transform().origin).rotated(axis, angle)
		end_pt += self.get_global_transform().origin
			
		vel_deflection = end_pt - start_pt
		dir_deflection = (end_pt - self.get_global_transform().origin).rotated(axis, deg2rad(90+15)).normalized()
	else:
		vel_remainder = col_projectile.travel.normalized() * 2.0
		
		#Calc angle to rotate around barrier
		angle = calc_rot_angle(vel_remainder)
		
		#Calc rotation axis
		var normal_surface = (col_projectile.position - self.get_global_transform().origin).normalized()
		var dir_barrier = (self.to_global(Vector3(0,0,-1)) - self.get_global_transform().origin).normalized()
		axis = dir_barrier.cross(normal_surface).normalized()
		
		#Calc vector from collision point to next point
		start_pt = col_projectile.position
		end_pt = (col_projectile.position - self.get_global_transform().origin).rotated(axis, angle)
		end_pt += self.get_global_transform().origin
			
		vel_deflection = Vector3(0,0,0)
		dir_deflection = (end_pt - self.get_global_transform().origin).rotated(axis, deg2rad(90)).normalized()
	
	deflection["direction"] = dir_deflection
	deflection["velocity"] = vel_deflection
	deflection["axis"] = axis
	deflection["angle"] = angle
	
	return deflection



#func deflect_projectile(col_projectile : KinematicCollision):
#	var angle : float
#	var axis : Vector3
#	var start_pt : Vector3
#	var end_pt : Vector3
#	var vel_deflection : Vector3
#
#	#Calc angle to rotate around barrier
#	angle = calc_rot_angle(col_projectile.remainder)
#
#	#Calc rotation axis
#	var normal_surface = (col_projectile.position - self.get_global_transform().origin).normalized()
#	axis = -col_projectile.remainder.cross(normal_surface).normalized()
#
##	if is_equal_approx(axis.length(), 0.0):
##		print(col_projectile.travel)
##		print(col_projectile.remainder)
##		print(normal_surface)
##		print(col_projectile.remainder.cross(normal_surface))
#
#	#Calc vector from collision point to next point
#	start_pt = col_projectile.position
#	end_pt = col_projectile.position.rotated(axis, angle)
#
#	vel_deflection = end_pt - start_pt
#
#	return vel_deflection


func route_projectile(pos_proj : Vector3, vel_proj : Vector3, speed_proj : float):
	pass


func calc_rot_angle(vel_remainder):
	var angle : float
	
	angle = vel_remainder.length()/barrier_radius
	
	return angle

