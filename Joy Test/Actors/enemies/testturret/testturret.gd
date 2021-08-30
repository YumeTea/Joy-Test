extends KinematicBody


#Node Storage
onready var Body = $Body
onready var ProjectileOrigin = $Body/ProjectileOrigin
onready var Timer_Fire = $Timer_Fire


#Targetting Vars
var target
var is_targetting : bool

#Projectile Vars
var projectile_scene_path : String = "res://Actors/enemies/testturret/projectile/TestProjectile.tscn"
onready var projectile_scene = load(projectile_scene_path)

#Firing Vars
var can_fire : bool = true
const fire_delay = 0.25


func _physics_process(delta):
	if is_targetting:
		aim(target)
		if can_fire:
			fire_projectile()


func aim(target_node):
	#Calc how much to rotate body to face target (2D for now)
	var dir_facing = Body.to_global(Vector3(0,0,-1)) - Body.get_global_transform().origin
	var dir_target = (target_node.get_global_transform().origin - Body.get_global_transform().origin).normalized()
	var angle_to_target = Vector2(dir_target.x, dir_target.z).angle_to(Vector2(dir_facing.x, dir_facing.z))
	
	#Rotate Body
	Body.rotate_y(angle_to_target)


func fire_projectile():
	#Create new instance of projectile scene/object
	var projectile = projectile_scene.instance()
	
	#Get initial values to pass to projectile
	var position = ProjectileOrigin.get_global_transform().origin
	var direction = ProjectileOrigin.to_global(Vector3(0,0,-1)) - ProjectileOrigin.get_global_transform().origin
	
	#Set initial values of projectile and add to main scene
	projectile.start(position, direction)
	get_tree().current_scene.add_child(projectile)
	
	#Start firing timer
	can_fire = false
	Timer_Fire.start(fire_delay)


func _on_Area_body_entered(body):
	if body == Global.get_player():
		target = body
		is_targetting = true


func _on_Area_body_exited(body):
	if body == Global.get_player():
		target = null
		is_targetting = false

func _on_Timer_Fire_timeout():
	can_fire = true
