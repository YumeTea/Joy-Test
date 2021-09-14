extends Node


signal set_scene_active(scene_active_flag)


var scene_is_active : bool = false


func _ready():
	pass # Replace with function body.


func _process(delta):
	if !scene_is_active:
		if Global.get_player() != null and Global.get_camera_main() != null:
			emit_signal("set_scene_active", true)
			scene_is_active = true

