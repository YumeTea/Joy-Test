extends KinematicBody


signal velocity_changed(velocity)
signal position_changed(position)


#Inventory Variables
const inventory_resource = preload("res://Resources/CustomResources/inventory_resource.gd")
var inventory = inventory_resource.new()


func _ready():
	###DEBUG?###
	Global.set_player(self)
	
	connect_motion_signals()
	
	###DEBUG
	self.inventory.debug_initialize_inventory()


#func _physics_process(delta):
#	if get_slide_count() > 1:
#		for col_idx in get_slide_count():
#			var collision = get_slide_collision(col_idx)
#			print(collision.collider_velocity)


func connect_motion_signals():
	var motion_state = $State_Machines/State_Machine_Move/Shared/Motion
	
	for area_state in motion_state.get_children():
		for move_state in area_state.get_children():
			move_state.connect("velocity_changed", self, "_on_velocity_changed")
	for area_state in motion_state.get_children():
		for move_state in area_state.get_children():
			move_state.connect("position_changed", self, "_on_position_changed")


func _on_velocity_changed(velocity):
	emit_signal("velocity_changed", velocity)


func _on_position_changed(position):
	emit_signal("position_changed", position)
