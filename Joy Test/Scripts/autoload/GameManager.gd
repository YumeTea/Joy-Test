extends Node


signal set_state_machines_active(active_flag)
signal gate_exited(gate_node)
signal initialize_player(transform)
signal transit_player_to_point(control_override_flag, position_node)
signal set_camera_main_state(state_name, transform)
signal set_camera_follow_on_input(flag)


const START_SCENE : String = "Test_Cell"
const START_GATE_IDX : int = 0

var player_resource = preload("res://Actors/player/Player.tscn")
var camera_main_resource = preload("res://Actors/camera_main/Camera_Main.tscn")

#Scene Change Vars
var next_scene_path : String = ""
var next_scene_type : String
var next_gate : Node
var next_gate_idx : int = -1
var is_entering_scene : bool = false
var is_exiting_scene : bool = false


func initialize_game():
	#Set gate index for next scene
	next_gate_idx = START_GATE_IDX
	next_scene_type = SceneDatabase.get_scene(START_SCENE).scene_type
	
	switch_to_scene(START_SCENE)


func _ready():
	SceneBackgroundLoader.connect("new_scene_loaded", self, "_on_new_scene_loaded")
	
	initialize_game()


func _process(delta):
	if is_entering_scene:
		if !get_tree().get_root().get_node("Main/Overlay_Main/AnimationPlayer").is_playing():
			emit_signal("transit_player_to_point", false, null)
			#Set camera_main to sleep state on entering new scene
			emit_signal("set_camera_follow_on_input", true)
			is_entering_scene = false


func spawn_player():
	var actors_node = get_tree().get_root().get_node("Main/Actors")
	var player = player_resource.instance()
	
#	#Send spawn point to player initialize function
#	var transform = next_gate.waypoint_spawn.get_global_transform()
#	player.initialize(transform)
	
	actors_node.add_child(player)
	Global.set_player(player)


func add_camera_main_to_scene():
	var actors_node = get_tree().get_root().get_node("Main/Actors")
	var camera_main = camera_main_resource.instance()
	
	
	actors_node.add_child(camera_main)
	Global.set_camera_main(camera_main)


func switch_to_scene(scene_name):
	#Queue SceneManager to switch to new scene
	SceneManager.switch_to_scene(scene_name)


func _on_new_scene_loaded():
	match next_scene_type:
		"menu":
			print("tried to switch to menu ???")
		"level":
			is_entering_scene = true
			
			for gate in get_tree().get_nodes_in_group("gate"):
				if gate.index == next_gate_idx:
					next_gate = gate
			
			#Add player and camera to scene, then activate their state machines
			spawn_player()
			add_camera_main_to_scene()
			emit_signal("set_state_machines_active", true)
			
			#Emit signal to have player move during scene entry
			emit_signal("initialize_player", next_gate.waypoint_spawn.get_global_transform())
			emit_signal("transit_player_to_point", true, next_gate.get_node("Waypoint_Enter"))
			
			#Emit signal for camera_main's state on scene entry
			var transform = null
			if next_gate.exit_camera_type in ["player_follow"]:
				transform = Global.get_player().get_node("Camera_Rig/Pivot/Camera_Controller/Camera_Pos").get_global_transform()
			elif next_gate.exit_camera_type in ["fixed_static", "fixed_track_player"]:
				transform = next_gate.get_node("Camera_Pos").get_global_transform()
			emit_signal("set_camera_main_state", next_gate.exit_camera_type, transform)
			
			#Connect to gate signals
			for gate in get_tree().get_nodes_in_group("gate"):
				gate.connect("player_entered_gate", self, "_on_player_entered_gate")
	
	#Start fade in on overlay
	get_tree().get_root().get_node("Main/Overlay_Main/AnimationPlayer").play("fade_in")


func _on_player_entered_gate(gate_node : Node):
	if Global.get_player() != null:
		#Emit signal to have player move to exit waypoint
		emit_signal("transit_player_to_point", true, gate_node.get_node("Waypoint_Exit"))
	
	#Set gate index for next scene if necessary
	match SceneDatabase.get_scene(gate_node.target_scene).scene_type:
		"menu":
			next_scene_type = SceneDatabase.get_scene(gate_node.target_scene).scene_type
			next_gate_idx = -1
		"level":
			next_scene_type = SceneDatabase.get_scene(gate_node.target_scene).scene_type
			next_gate_idx = gate_node.target_gate_idx
	
	switch_to_scene(gate_node.target_scene)









