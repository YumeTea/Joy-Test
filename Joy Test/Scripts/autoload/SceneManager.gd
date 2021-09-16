extends Node

#Scene Vars
var next_scene_path : String = ""


var scene_is_active : bool = false
var is_exiting_scene : bool = false
var is_entering_scene : bool = false


func _ready():
	SceneBackgroundLoader.connect("new_scene_loaded", self, "_on_new_scene_loaded")


func _process(delta):
#	if !scene_is_active:
#		if Global.get_player() != null and Global.get_camera_main() != null:
#			emit_signal("set_scene_active", true)
#			scene_is_active = true
	
	
	if is_exiting_scene:
		if get_tree().get_root().get_node("Main/Overlay_Main/AnimationPlayer").is_playing():
			return
		SceneBackgroundLoader.goto_scene(next_scene_path)
		is_exiting_scene = false
		return
	if is_entering_scene:
		if get_tree().get_root().get_node("Main/Overlay_Main/AnimationPlayer").is_playing():
			return
		is_entering_scene = false
		set_process(false)


func switch_to_scene(scene_name):
	next_scene_path = SceneDatabase.get_scene(scene_name).scene_path
	
	is_exiting_scene = true
	if get_tree().get_root().get_node("Main/Overlay_Main/ColorRect").color != Color(0,0,0,1):
		get_tree().get_root().get_node("Main/Overlay_Main/AnimationPlayer").play("fade_out")
	set_process(true)


func _on_new_scene_loaded():
	next_scene_path = ""
	
	is_entering_scene = true








