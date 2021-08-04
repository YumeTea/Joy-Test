extends Label


func update_display(height):
	self.text = "Height: " + str(height)


func _on_Debug_UI_player_height_changed(height):
	update_display(height)















