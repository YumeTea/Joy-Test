extends KinematicBody


export var start_pos : Vector3
export var stop_pos : Vector3

var move_dir : Vector3
var velocity : Vector3 = Vector3(0,0,0)
var accel = 0.1
var deaccel = 0.1
var max_speed = 22

#Elevator flags
var is_ascending = false


func _ready():
	move_dir = (stop_pos - start_pos).normalized()


func _physics_process(delta):
	if is_ascending:
		velocity += move_dir * accel * delta
		if velocity.length() >= max_speed:
			velocity += move_dir * max_speed * delta
		
		var next_pos = self.translation + velocity
		if (stop_pos - next_pos).dot(move_dir) >= 0.0:
			self.translation += velocity
		else:
			self.translation = stop_pos
			velocity = Vector3(0,0,0)
	elif !is_ascending:
		if velocity.dot(move_dir) > 0.0:
			velocity -= move_dir * deaccel * delta
		else:
			velocity -= move_dir * accel * delta
			if velocity.length() >= max_speed:
				velocity -= -move_dir * max_speed * delta
		
		var next_pos = self.translation + velocity
		#Check if past stop_pos
		if velocity.dot(move_dir) > 0.0:
			if (stop_pos - next_pos).dot(move_dir) < 0.0:
				self.translation = stop_pos
				velocity = Vector3(0,0,0)
			else:
				self.translation += velocity
		#Checi if past start_pos
		elif velocity.dot(-move_dir) > 0.0:
			if (start_pos - next_pos).dot(-move_dir) < 0.0:
				self.translation = start_pos
				velocity = Vector3(0,0,0)
			else:
				self.translation += velocity
	
	self.force_update_transform()

func set_is_ascending(value : bool):
	is_ascending = value


func _on_Area_body_entered(body):
	if body == Global.get_player():
		set_is_ascending(true)


func _on_Area_body_exited(body):
	if body == Global.get_player():
		set_is_ascending(false)

