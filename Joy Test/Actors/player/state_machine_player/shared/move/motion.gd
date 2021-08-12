extends "res://Actors/player/state_machine_player/shared/shared.gd"

'figure out why is_on_floor isnt set on rising platforms'

signal velocity_changed(velocity)
signal height_changed(height)


#Initialized values storage
var initialized_values : Dictionary


##Movement Variables
#Limits
var run_speed_full = 24.0
var run_full_time = 0.875
var ledge_move_speed_full = 2.625
var ledge_move_full_time = 0.875
var air_speed_full = 8.0
var speed_thresh_lower = 0.1

#Values
var weight = 5.0
var gravity = -9.8
var walk_accel = 16
var walk_deaccel = 16
var air_accel = 1.375
var air_deaccel = 1.375

##Motion Variables##
var velocity : Vector3
var velocity_ext : Vector3 #used for adding velocity applied from out of state machine scripts
var snap_vector : Vector3
var snap_vector_default = Vector3(0, -1, 0)

#Floor Fasten variables
var attached_pos = null #attached point local to object player is standing on
var attached_dir = null
var attached_dir_prev = null
var attached_floor = null
var velocity_fasten : Vector3

#Wall Jump Variables
var wall_col = null

#Ledge Hang Variables
var grab_data = {
	"grab_obj": null,
	"grab_point": null,
	"grab_dir": null,
	"ledge_move_dir": null,
}
var hang_obj : Node
var hang_point : Vector3 #point is local to hang_obj
var hang_dir : Vector3
var hang_dir_prev : Vector3
var ledge_up : Vector3

#Node Storage
onready var Collision = owner.get_node("CollisionShape")

onready var Ledge_Detector = owner.get_node("Body/Ledge_Detector")
onready var Ledge_Grab_Position = owner.get_node("Body/Position_Nodes/Ledge_Grab_Position")

onready var RayCast_Floor = owner.get_node("CollisionShape/RayCast_Floor")

onready var Timer_Move = owner.get_node("State_Machines/State_Machine_Move/Timer_Move")
onready var Timer_Wall_Jump = owner.get_node("State_Machines/State_Machine_Move/Timer_Wall_Jump")
onready var Timer_Ledge_Grab = owner.get_node("State_Machines/State_Machine_Move/Timer_Ledge_Grab")

onready var AnimStateMachineMotion = owner.get_node("AnimationTree").get("parameters/BlendTreeMotion/StateMachineMotion/playback")

#Motion Flags
var stop_on_slope = true
var fasten_to_floor = true
var fasten_to_ledge = false
var can_wall_jump = false
var can_ledge_grab = true


#Initializes state, changes animation, etc
func enter():
	connect_local_signals()


#Cleans up state, reinitializes values like timers
func exit():
	#Reset motion anim time scale on every state switch
	AnimTree.set("parameters/BlendTreeMotion/TimeScaleMotion/scale", 1.0)
	
	disconnect_local_signals()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	#Add external velocities (from outside this state machine)
	if velocity_ext != Vector3(0,0,0):
		velocity = add_velocity_ext(velocity, velocity_ext)
	
	#Add gravity
	velocity.y += (gravity * weight * delta)
	
	#Move player
	velocity = owner.move_and_slide_with_snap(velocity, snap_vector, Vector3(0, 1, 0), stop_on_slope, 4, deg2rad(50))
	
	print(owner.get_slide_count())
	print(owner.is_on_floor())
	
	#Set total velocity for readouts
	velocity += velocity_fasten
	
	#Get new ground fasten point and dir
	set_fasten_vectors()
	
	#DEBUG FOR UI
	emit_signal("velocity_changed", velocity)
	emit_signal("height_changed", owner.get_global_transform().origin.y)


func _on_animation_finished(_anim_name):
	return


###MOTION FUNCTIONS###
func rotate_to_direction(direction): #Direction should be normalized
	if direction is Vector3:
		direction = Vector2(direction.x, direction.z)
	
	if direction.length() > 0:
		var angle_y = Vector2(0, 1).angle_to(-direction) #calc degree of player rotation on y axis
		
		var rot_final = Body.get_rotation()
		rot_final.y = -angle_y
		
		Body.set_rotation(rot_final)
		return angle_y
	else:
		return null


#Used for adding jab recoil velocity
func add_velocity_ext(velocity, velocity_ext):
	var v_dot_ext : float
	var v_ext : Vector3
	var v_current : Vector3
	var v_new : Vector3
	
	v_ext = velocity_ext.normalized()
	v_current = velocity.normalized()
	
	v_dot_ext = max(0, v_ext.dot(v_current))
	
	v_new = velocity_ext + (velocity * v_dot_ext)
	
	clear_velocity_ext()
	
	return v_new


func clear_velocity_ext():
	velocity_ext = Vector3(0,0,0)


###MOTION FLAG FUNCTIONS###
func set_stop_on_slope(value : bool):
	State_Machine_Move.current_state.stop_on_slope = value


func set_fasten_to_floor(value : bool):
	State_Machine_Move.current_state.fasten_to_floor = value


func set_fasten_to_ledge(value : bool):
	State_Machine_Move.current_state.fasten_to_ledge = value


func set_can_wall_jump(value):
	State_Machine_Move.current_state.can_wall_jump = value
	
	if value == true:
		Timer_Wall_Jump.start()
	elif value == false:
		Timer_Wall_Jump.stop()
		


func set_can_ledge_grab(value):
	State_Machine_Move.current_state.can_ledge_grab = value


###MOTION VAR SETTER FUNCTIONS###
func set_wall_col(collision):
	State_Machine_Move.current_state.wall_col = collision


func set_fasten_vectors():
	attached_pos = null
	attached_dir = null
	attached_floor = null
	
	RayCast_Floor.force_raycast_update()
	
	if RayCast_Floor.is_colliding() and owner.is_on_floor():
		var collision : KinematicCollision
		
		for col_idx in owner.get_slide_count():
			collision = owner.get_slide_collision(col_idx)
			
			if collision.collider == RayCast_Floor.get_collider():
				attached_floor = collision.collider
				attached_pos = attached_floor.to_local(RayCast_Floor.get_collision_point())
				attached_dir = attached_floor.to_local(get_facing_direction_horizontal(Body))
				attached_dir_prev = attached_floor.to_global(attached_dir) - attached_floor.get_global_transform().origin
				return


#Stores values of the current state in the top level state machine's dict, for transfer to another state
#Called from main state machine
func store_initialized_values(init_values_dic):
	for value in init_values_dic:
		init_values_dic[value] = self[value]


func connect_local_signals():
	owner.get_node("Body/Ledge_Detector").connect("ledge_detected", self, "_on_ledge_detected")
	owner.get_node("Camera_Rig").connect("camera_angle_changed", self, "_on_Camera_Rig_camera_angle_changed")
	owner.get_node("State_Machines/State_Machine_Action_L").connect("action_l_state_changed", self, "_on_State_Machine_Action_L_state_changed")
	owner.get_node("State_Machines/State_Machine_Action_R").connect("action_r_state_changed", self, "_on_State_Machine_Action_R_state_changed")
	owner.get_node("State_Machines/State_Machine_Action_R/Shared/Action_R/Jab").connect("jab_collision", self, "_on_jab_collision")
	owner.get_node("State_Machines/State_Machine_Action_R/Shared/Action_R/Jab_Aim").connect("jab_collision", self, "_on_jab_collision")
	
	owner.get_node("State_Machines/State_Machine_Move/Timer_Aim").connect("timeout", self, "_on_Timer_Aim_timeout")
	owner.get_node("State_Machines/State_Machine_Move/Timer_Move").connect("timeout", self, "_on_Timer_Move_timeout")
	owner.get_node("State_Machines/State_Machine_Move/Timer_Wall_Jump").connect("timeout", self, "_on_Timer_Wall_Jump_timeout")
	owner.get_node("State_Machines/State_Machine_Move/Timer_Ledge_Grab").connect("timeout", self, "_on_Timer_Ledge_Grab_timeout")
	
	owner.get_node("AnimationPlayer").connect("animation_finished", self, "_on_animation_finished")


func disconnect_local_signals():
	owner.get_node("Body/Ledge_Detector").disconnect("ledge_detected", self, "_on_ledge_detected")
	owner.get_node("Camera_Rig").disconnect("camera_angle_changed", self, "_on_Camera_Rig_camera_angle_changed")
	owner.get_node("State_Machines/State_Machine_Action_L").disconnect("action_l_state_changed", self, "_on_State_Machine_Action_L_state_changed")
	owner.get_node("State_Machines/State_Machine_Action_R").disconnect("action_r_state_changed", self, "_on_State_Machine_Action_R_state_changed")
	owner.get_node("State_Machines/State_Machine_Action_R/Shared/Action_R/Jab").disconnect("jab_collision", self, "_on_jab_collision")
	owner.get_node("State_Machines/State_Machine_Action_R/Shared/Action_R/Jab_Aim").disconnect("jab_collision", self, "_on_jab_collision")
	
	owner.get_node("State_Machines/State_Machine_Move/Timer_Aim").disconnect("timeout", self, "_on_Timer_Aim_timeout")
	owner.get_node("State_Machines/State_Machine_Move/Timer_Move").disconnect("timeout", self, "_on_Timer_Move_timeout")
	owner.get_node("State_Machines/State_Machine_Move/Timer_Wall_Jump").disconnect("timeout", self, "_on_Timer_Wall_Jump_timeout")
	owner.get_node("State_Machines/State_Machine_Move/Timer_Ledge_Grab").disconnect("timeout", self, "_on_Timer_Ledge_Grab_timeout")
	
	owner.get_node("AnimationPlayer").disconnect("animation_finished", self, "_on_animation_finished")


###LOCAL SIGNAL COMMS###
func _on_ledge_detected(grab_dict):
	grab_data = grab_dict


func _on_State_Machine_Action_L_state_changed(action_l_state):
	pass


func _on_State_Machine_Action_R_state_changed(action_r_state):
	pass


func _on_Timer_Move_timeout():
	pass


func _on_Timer_Aim_timeout():
	set_aiming(false)


func _on_Timer_Ledge_Grab_timeout():
	set_can_ledge_grab(true)


func _on_Timer_Wall_Jump_timeout():
	State_Machine_Move.current_state.set_can_wall_jump(false)


func _on_jab_collision(collision):
	var col_material = collision["col_material"]
	
	##SOLID COLLISION
	if col_material in GlobalValues.collision_materials_solid:
		velocity_ext += collision["recoil_vel"]
	
	##SOFT COLLISION
	elif col_material in GlobalValues.collision_materials_soft:
		attached_obj = collision["collider"]
		emit_signal("state_switch", "stick_wall")
		return


func _on_Camera_Rig_camera_angle_changed(angles):
	camera_angles = angles



