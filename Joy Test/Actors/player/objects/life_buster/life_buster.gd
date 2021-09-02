extends KinematicBody


#Projectile Variables
var damage_dealt = 64
var speed = 120
var turn_radius = deg2rad(3)
var bob_speed = 6
var despawn_time = 15 #in seconds
var uturn
var location
var direction = Vector3()
var velocity = Vector3()
var collision

#Target Variables
var target
var target_loc
var target_dir #Direction to target

#Glow Variables
onready var light = get_node("CollisionShape/glow")
onready var mesh = get_node("CollisionShape/MeshInstance")
var glow_oscillation
var time
var time_init
var time_offset = 0.0006599
var range_default = 1.4

#Node Storage
onready var timer = get_node("Timer")

#Random Number Draw
onready var rand_num = rand()

#Impact Scene
var impact_scene = preload("res://Actors/player/objects/life_buster/impact/Life_Buster_Impact.tscn")



func _ready():
	#Set Despawn Timer
	timer.set_wait_time(despawn_time)
	timer.start(despawn_time)


func _process(delta):
	time = (OS.get_ticks_msec() * time_offset) + rand_num
	projectile_path(delta, time)
	glow(delta, time)
#	bob(delta, time)
	pulse(time)


func start(start_loc_init, direction_init):
	transform = start_loc_init #Start transform is caster transform
	direction = direction_init #Start direction is caster direction normalized


func projectile_path(delta, _time):
	$CollisionShape.disabled = false
	
	location = transform.origin
	
	###Projectile Velocity
	velocity = direction * speed * delta
	
	###Projectile Movement
	
	###Projectile Movement and Collision
	collision = move_and_collide(velocity, false, false, true)
	
	if collision:
		impact(collision)
	else:
		velocity = move_and_collide(velocity, false, false)
	
	$CollisionShape.disabled = true


func impact(collision):
	var col_pt = collision.get_position()
	var impact = impact_scene.instance()
	
	get_tree().current_scene.add_child(impact)
	
	impact.global_transform.origin = col_pt
	
	queue_free()


# warning-ignore:shadowed_variable
func glow(_delta, time):
	glow_oscillation = ((abs(cos(time)) + 1.5) / 3.0) * range_default
	$CollisionShape/glow.set_param(3, glow_oscillation)


# warning-ignore:shadowed_variable
#func bob(_delta, time):
#	$CollisionShape.transform.origin.y = (sin(time * bob_speed)) * 0.5
#	$CollisionShape.transform.origin.x = cos(time * bob_speed * 0.5)
#	$CollisionShape.transform.origin.z = sin(time * bob_speed * 0.8)


# warning-ignore:shadowed_variable
func pulse(time):
	mesh.get_surface_material(0).set_shader_param("time", time)
	mesh.get_surface_material(0).set_shader_param("time2", time)


func rand():
	var nums = [30,61,57,6,34,32,51,49,22,52,60,47,12,43,1,7,10,18,38,0,21,2,5,28,14,13,45,36,35,11,25,4,59,29,62,16,37,17,20,44,23,24,53,58,42,48,54,27,50,8,56,9,33,55,64,31,46,19,41,3,40,15,39,26] #list to choose from
	return nums[randi() % nums.size()]


func _on_Timer_timeout():
	queue_free()

