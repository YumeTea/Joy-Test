extends Area


signal player_entered_gate


export var index : int
export (String, "default", "walkin", "descend") var gate_type
export var target_scene : String
export var target_gate_idx : int
















func _on_Gate_body_entered(body):
	if body == Global.get_player():
		GameManager.switch_to_scene(target_scene, target_gate_idx)







