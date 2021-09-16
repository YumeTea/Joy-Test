extends Area


signal player_entered_gate(self_gate_type, scene_name, gate_idx)


export var index : int
export var target_scene : String
export var target_gate_idx : int
export (String, "default", "walkin", "descend") var gate_type
export (String, "player_follow", "fixed_track_player", "fixed_static") var exit_camera_type = "player_follow"
export var camera_pos_offset : Vector3 = Vector3()


#Node Refs
onready var waypoint_spawn : Position3D = $Waypoint_Spawn
onready var waypoint_enter : Position3D = $Waypoint_Enter
onready var waypoint_exit : Position3D = $Waypoint_Exit



func _ready():
	$Camera_Pos.translate(camera_pos_offset)










func _on_Gate_body_entered(body):
	if body == Global.get_player():
		emit_signal("player_entered_gate", self)







