extends "res://Actors/camera_main/state_machine_camera_main/shared/shared.gd"


const translate_speed_max : float = 0.4

#Camera Track Flags
var on_target : bool = false


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	if Global.get_player():
		set_camera_target(Global.get_player().get_node("Camera_Rig/Pivot/Camera_Controller/Camera_Pos"))
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
#	print(on_target)
	follow_camera_pos(delta)
	
	.update(delta)


func _on_animation_finished(_anim_name):
	return


func follow_camera_pos(delta):
	var translate : Vector3
	
	if (owner.get_global_transform().origin != camera_target.get_global_transform().origin) and !on_target:
		translate = camera_target.get_global_transform().origin - owner.get_global_transform().origin
		if translate.length() > translate_speed_max:
			translate = translate.normalized() * translate_speed_max
		
		owner.global_translate(translate)
		
		owner.set_global_transform(owner.get_global_transform().looking_at(camera_target.get_parent().get_parent().get_global_transform().origin, Vector3(0,1,0)))
	else:
		on_target = true
		owner.set_global_transform(camera_target.get_global_transform())
	


#func follow_camera_pos(delta):
#	owner.set_global_transform(camera_target.get_global_transform())
