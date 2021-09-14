extends Node


signal new_scene_loaded


var loader
var wait_frames : int
const time_max : int = 100 #in msec
var main_scene : Node
var level_scene_resource : Resource


#Loading Screen Vars
var loading_scene : Node
var loading_scene_ref = preload("res://Levels/Loading_Screen/Loading_Screen.tscn")


func _ready():
	set_process(false)
	var root = get_tree().get_root()
	main_scene = root.get_child(root.get_child_count() - 1)


func _process(delta):
	if loader == null:
		if main_scene.get_node("Overlay_Main/AnimationPlayer").is_playing():
			return
		#add scene to scene tree when loader is cleared
		#stop processing if loader was cleared i.e. when loading was finished
		set_new_scene(level_scene_resource)
		set_process(false)
		return
	
	#Wait for wait_frames to let the loading screen show up
	if wait_frames > 0:
		wait_frames -= 1
		return
	###DEBUG###
	if main_scene.get_node("Overlay_Main/AnimationPlayer").is_playing():
		return
	
	var t = OS.get_ticks_msec()
	#time_max controls how long this thread is blocked
	while OS.get_ticks_msec() < t + time_max:
		#Poll loader to load next stage of scene
		var err = loader.poll()
		
		if err == ERR_FILE_EOF: #if all stages loaded
			level_scene_resource = loader.get_resource()
			loader = null
			#Fade out loading screen
			main_scene.get_node("Overlay_Main/AnimationPlayer").play("fade_out")
			break
		elif err == OK: #if no errors returned on polling loader
			#update_progress()
			pass
		else: #if loader poll returned erroneous result
			assert (err == OK, "Error while polling ResourceInteractiveLoader")
#			loader = null
#			break


"Find  more elegant way to parse scene structure"
func goto_scene(scene_path : String):
	#get a ResourceInteractiveLoader and passes it the scene to load
	loader = ResourceLoader.load_interactive(scene_path)
	if loader == null: #if error retrieving interactive loader
		print("Error retrieving interactive loader for scene_path")
		return
	set_process(true)
	
	#Clear current level from scene tree
	for node in main_scene.get_children():
		if !(node is CanvasLayer):
			for child in node.get_children():
				child.queue_free()
	
	#Add loading scene to scene tree and fade into load screen
	loading_scene = loading_scene_ref.instance()
	for node in main_scene.get_children():
		if node.name == "Level":
			node.add_child(loading_scene)
			main_scene.get_node("Overlay_Main/AnimationPlayer").play("fade_in")
			break
	
	#Start loading animation (if there is one)
#	loading_scene.get_node("AnimationPlayer").play("loading")
	
	wait_frames = 1 #give 1 frame for loading scene to show up before loading


func set_new_scene(scene_resource : Resource):
	#Remove loading scene
	loading_scene.queue_free()
	
	#Instance loaded scene
	var scene = scene_resource.instance()
	
	#Add scene to appropriate parent node
	for node in main_scene.get_children():
		if node.name == "Level":
			node.add_child(scene)
			break
	
	#Emit new scene loaded signal
	emit_signal("new_scene_loaded")
















