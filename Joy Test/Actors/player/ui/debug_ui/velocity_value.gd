extends Label


func update_display(speed):
	self.text = "Velocity Horizontal: " + str(speed)




func _on_Debug_UI_player_velocity_changed(velocity):
	var speed_horizontal = Vector3(velocity.x, 0, velocity.z).length()
	update_display(speed_horizontal)
