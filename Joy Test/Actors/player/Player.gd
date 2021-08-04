extends KinematicBody


signal velocity_changed(velocity)
signal height_changed(height)


#Inventory Variables
const inventory_resource = preload("res://Resources/CustomResources/inventory_resource.gd")
var inventory = inventory_resource.new()


func _ready():
	connect_motion_signals()
	
	###DEBUG
	self.inventory.debug_initialize_inventory()


func connect_motion_signals():
	var motion_state = $State_Machines/State_Machine_Move/Shared/Motion
	
	for area_state in motion_state.get_children():
		for move_state in area_state.get_children():
			move_state.connect("velocity_changed", self, "_on_velocity_changed")
	for area_state in motion_state.get_children():
		for move_state in area_state.get_children():
			move_state.connect("height_changed", self, "_on_height_changed")


func _on_velocity_changed(velocity):
	emit_signal("velocity_changed", velocity)


func _on_height_changed(height):
	emit_signal("height_changed", height)
