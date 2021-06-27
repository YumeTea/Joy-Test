extends "res://Actors/player/state_machine_player/shared/move/in_air/in_air.gd"

'need to prevent player from climbing higher using this state'
'player should fail to jump if they collide with the level before jumping'

#Jump Variables
var jump_velocity = 24


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
#	has_jumped = false
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	.update(delta)


func _on_animation_finished(_anim_name):
	return


func calc_air_speed(velocity):
	pass


#Call this function in future animation
func add_jump_velocity(velocity):
	velocity.y = jump_velocity
	snap_vector = Vector3(0,0,0) #disable snap vector so player can leave floor
	has_jumped = true
	
	return velocity




