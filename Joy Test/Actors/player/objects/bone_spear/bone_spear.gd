extends MeshInstance

onready var Raycast = self.get_node("RayCast")
var colliding = false


func _process(delta):
	if Raycast.is_colliding() and colliding == false:
		print("Bone Spear striking wall")
		colliding = true
	if !Raycast.is_colliding() and colliding == true:
		print("Bone Spear exited wall")
		colliding = false
