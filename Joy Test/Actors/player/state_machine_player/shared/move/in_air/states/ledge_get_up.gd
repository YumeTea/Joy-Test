extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"


'can animate position in jump/climb up animation'
'kick_off_ledge needs to abort anims'


signal on_ledge(on_ledge_flag)


var hang_obj : Node
var attached_point : Vector3
var attached_dir : Vector3
var ledge_up : Vector3
var velocity_fasten : Vector3

var ledge_detector_default : Vector3
var ledge_grab_position_default : Vector3
export var translation : Vector3
var translation_last : Vector3
var climb_velocity : Vector3


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	ledge_detector_default = Ledge_Detector.get_translation()
	ledge_grab_position_default = Ledge_Grab_Position.get_translation()
	translation = Vector3(0,0,0)
	translation_last = Vector3(0,0,0)
	climb_velocity = Vector3(0,0,0)
	
	hang_obj = grab_data["grab_obj"]
	attached_point = hang_obj.to_local(grab_data["grab_point"])
	attached_dir = hang_obj.to_local(grab_data["grab_dir"] + hang_obj.get_global_transform().origin)
	
	anim_tree_play_anim("ledge_get_up", AnimStateMachineMotion)
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	reset_ledge_detection()
	emit_signal("on_ledge", false)
	
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("cancel"):
		kick_off_ledge()
		emit_signal("state_switch", "fall")
		return
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if grab_data["grab_point"] == null:
		print("lost grab point")
		kick_off_ledge()
		emit_signal("state_switch", "fall")
		return
	
	translate_ledge_get_up(translation)
	
	velocity = calc_ledge_velocity(delta)
	
	.update(delta)


func _on_animation_finished(anim_name):
	return


func calc_ledge_velocity(delta):
	var new_vel = Vector3(0,0,0)
	
	#Calc ledge attachment velocity
	velocity_fasten = fasten_to_ledge(hang_obj, attached_point, grab_data["grab_dir"], delta)
	new_vel += velocity_fasten
	
	#Counteract gravity
	new_vel.y -= (gravity * weight * delta)
	
	return new_vel


#Applies velocity while following ledge grab point
func fasten_to_ledge(hang_obj, attached_point, face_dir, delta):
	var grab_point : Vector3
	var grab_dir : Vector3
	var vel_new : Vector3
	var angle : float
	
	grab_point = hang_obj.to_global(attached_point)
	grab_dir = hang_obj.to_global(attached_dir) - hang_obj.get_global_transform().origin
	
	rotate_about_grab_point(grab_point, Vector2(grab_dir.x, grab_dir.z))
	
	vel_new = (grab_point - Ledge_Grab_Position.get_global_transform().origin) / delta
	
	return vel_new


func kick_off_ledge():
	set_can_ledge_grab(false)
	Timer_Ledge_Grab.start()
	emit_signal("on_ledge", false)


func reset_ledge_detection():
	Ledge_Detector.set_translation(ledge_detector_default)
	Ledge_Grab_Position.set_translation(ledge_grab_position_default)


###ANIMATION FUNCTIONS###
func translate_ledge_get_up(translation):
	var translate : Vector3
	
	translate = translation - translation_last
	
	#Translate player and translate ledge detector the opposite way
	owner.global_transform.origin += translate
	Ledge_Detector.translation -= translate
	Ledge_Grab_Position.translation -= translate
	
	translation_last = translation


func set_ledge_climb_velocity(velocity):
	climb_velocity = velocity










