extends Node


const START_SCENE : String = "Test_Cell"
const START_GATE_IDX : int = 0

var player_resource = preload("res://Actors/player/Player.tscn")
var camera_main_resource = preload("res://Actors/camera_main/Camera_Main.tscn")

#Scene Change Vars
var next_scene_path : String = ""
var is_entering_scene : bool = false
var is_exiting_scene : bool = false


func _ready():
	set_process(false)
	
	SceneBackgroundLoader.connect("new_scene_loaded", self, "_on_new_scene_loaded")
	
	#Load game starting scene
	switch_to_scene(START_SCENE)


func _process(delta):
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


func spawn_player():
	var actors_node = get_tree().get_root().get_node("Main/Actors")
	var player = player_resource.instance()
	
	actors_node.add_child(player)
	Global.set_player(player)


func add_camera_main_to_scene():
	var actors_node = get_tree().get_root().get_node("Main/Actors")
	var camera_main = camera_main_resource.instance()
	
	actors_node.add_child(camera_main)
	Global.set_camera_main(camera_main)


func switch_to_scene(scene_name, gate_idx : int = -1):
	next_scene_path = SceneDatabase.get_scene(scene_name).scene_path
	
	is_exiting_scene = true
	get_tree().get_root().get_node("Main/Overlay_Main/AnimationPlayer").play("fade_out")
	set_process(true)


func _on_new_scene_loaded():
	next_scene_path = ""
	
	spawn_player()
	add_camera_main_to_scene()
	get_tree().get_root().get_node("Main/Overlay_Main/AnimationPlayer").play("fade_in")
	is_entering_scene = true
	
	###DEBUG###
	SceneManager.scene_is_active = false


