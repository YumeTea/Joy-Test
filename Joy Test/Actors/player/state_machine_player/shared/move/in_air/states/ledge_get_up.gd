extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"


'kick_off_ledge needs to abort anims'
'needs more testing on fast moving platforms'


signal on_ledge(on_ledge_flag)

var ledge_detector_default : Vector3
var ledge_grab_position_default : Vector3
export var translation : Vector3 #value is animated by animplayer
var translation_last : Vector3
var climb_velocity : Vector3


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	velocity = Vector3(0,0,0)
	velocity_fasten = Vector3(0,0,0)
	ledge_detector_default = Ledge_Detector.get_translation()
	ledge_grab_position_default = Ledge_Grab_Position.get_translation()
	translation = Vector3(0,0,0)
	translation_last = Vector3(0,0,0)
	climb_velocity = Vector3(0,0,0)
	
	hang_obj = grab_data["grab_obj"]
	hang_point = hang_obj.to_local(grab_data["grab_point"])
	hang_dir = hang_obj.to_local(grab_data["grab_dir"] + hang_obj.get_global_transform().origin)
	
	anim_tree_play_anim("ledge_get_up", AnimStateMachineMotion)
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	reset_ledge_detection()
	
	#REPLACE LATER IF KICKING OFF LEDGE DUE TO COLLISION
	velocity = Vector3(0,0,0)
	velocity_fasten = Vector3(0,0,0)
	set_fasten_to_ledge(false)
	set_arm_r_occupied(false)
	emit_signal("on_ledge", false)
	
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("cancel"):
		let_go_ledge()
		emit_signal("state_switch", "fall")
		return
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	if grab_data["grab_point"] == null:
		let_go_ledge()
		emit_signal("state_switch", "fall")
		return
	
	#Apply translation sent from animation
	translate_ledge_get_up(translation)
	
	#Remove fasten v from total v
	velocity -= velocity_fasten
	
	#Counteract gravity
	velocity = Vector3(0,0,0)
	velocity.y = weight * gravity * delta
	
	.update(delta)


func _on_animation_finished(anim_name):
	return


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










