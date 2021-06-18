extends Node



func _ready():
	OS.set_window_fullscreen(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


#func _input(event):
#	if event is InputEventAction:
#		pass


func _process(delta):
	if Input.is_action_just_pressed("dev_quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("dev_mouse_control"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)






