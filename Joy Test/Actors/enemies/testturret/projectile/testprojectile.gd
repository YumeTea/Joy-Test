extends KinematicBody


#Projectile Constants
const speed = 64
const timeout = 10
const col_layer_def = 0xA

#Projectile Vars
var direction : Vector3
var velocity : Vector3
var collision = null
var deflection = {
	"direction": Vector3(),
	"velocity": Vector3(),
	"axis": Vector3(),
	"angle": 0.0,
}

#Projectile Flags
var deflecting = false


#Sets initial transformation and velocity when called, start deletion timer
func start(position_start : Vector3, direction_start : Vector3):
	translation = position_start
	direction = direction_start
	velocity = direction * speed


func _ready():
	$Timer_Range.start(timeout)


func _physics_process(delta):
	$CollisionShape.disabled = false
	collision = move_and_collide(velocity * delta)
	
	if collision is KinematicCollision:
		if collision.collider.is_in_group("barrier_player"):
			#Disable collision with barrier while deflecting
			self.set_collision_mask_bit(3, false)
			#Get deflection vel from barrier, check for col with non barrier objects, set next velocity
			deflection = collision.collider.deflect_projectile(collision)
			velocity = deflection["velocity"]
			collision = move_and_collide(velocity)
			
			#Set next velocity to be slightly into barrier
			velocity = deflection["direction"] * speed
			
			#Re-enable default colliison layers
			self.set_collision_mask_bit(3, true)
			
		if collision is KinematicCollision:
			impact()
	
	$CollisionShape.disabled = true


func impact():
	queue_free()


func _on_Timer_Range_timeout():
	queue_free()

