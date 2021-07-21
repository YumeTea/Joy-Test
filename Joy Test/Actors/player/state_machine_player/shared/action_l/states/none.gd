extends "res://Actors/player/state_machine_player/shared/action_l/action_l.gd"


func initialize_values(init_values_dic):
	for value in init_values_dic:
		self[value] = init_values_dic[value]


#Initializes state, changes animation, etc
func enter():
	AnimStateMachineActionL.start("none")
	
	AnimTree.set("parameters/MotionActionLBlend/blend_amount", 0.0)
	
	.enter()


#Cleans up state, reinitializes values like timers
func exit():
	AnimTree.set("parameters/MotionActionLBlend/blend_amount", 0.01)
	.exit()


#Creates output based on the input event passed in
func handle_input(event):
	if Input.is_action_just_pressed("attack_left"):
		#Branch to correct state based on equipped spell type
		match current_spell.spell_type:
			"projectile":
				if !is_aiming:
					emit_signal("state_switch", "cast")
				elif is_aiming:
					emit_signal("state_switch", "cast_aim")
			"barrier":
				pass
			"held_affect":
				pass
	
	.handle_input(event)


#Acts as the _process method would
func update(delta):
	.update(delta)


func _on_animation_finished(anim_name):
	._on_animation_finished(anim_name)

