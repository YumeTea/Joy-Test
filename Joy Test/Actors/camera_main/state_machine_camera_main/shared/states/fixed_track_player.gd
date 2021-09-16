extends "res://Actors/camera_main/state_machine_camera_main/shared/shared.gd"

"Issues if attempting to track camera controller on camera rig"


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	if Global.get_player():
		set_camera_target(Global.get_player().get_node("Camera_Rig/Pivot"))
	else:
		print("scene active before fully loaded")
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	set_camera_target(null)
	
	.exit()


#Creates output based on the input event passed in
func handle_input(_event):
	return


#Acts as the _process method would
func update(delta):
	track_player()
	
	.update(delta)


func _on_animation_finished(_anim_name):
	return


func track_player():
	var transform : Transform
	
	transform = owner.get_global_transform().looking_at(camera_target.get_global_transform().origin, Vector3(0,1,0))
	
	owner.set_global_transform(transform)

