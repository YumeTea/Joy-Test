extends Label


func update_display(speed_horizontal, speed_vertical):
	self.text = "Velocity Horizontal: " + str(speed_horizontal) + "\n"
	self.text += "Velocity Vertical: " + str(speed_vertical)




func _on_Debug_UI_player_velocity_changed(velocity):
	var speed_horizontal = Vector3(velocity.x, 0, velocity.z).length()
	var speed_vertical = velocity.y
	update_display(speed_horizontal, speed_vertical)
