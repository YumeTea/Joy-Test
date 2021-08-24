extends Label


func update_display(position):
	self.text = "Position: " + str(position)


func _on_Debug_UI_player_position_changed(position):
	update_display(position)

















