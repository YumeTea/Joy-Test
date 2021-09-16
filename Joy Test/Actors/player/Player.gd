extends KinematicBody


signal velocity_changed(velocity)
signal position_changed(position)
signal equipped_items_changed(equipped_items)
signal player_entered_gate(gate_node)


#Inventory Variables
const inventory_resource = preload("res://Resources/CustomResources/inventory_resource.gd")
var inventory = inventory_resource.new()


func initialize(start_transform : Transform):
	translation = start_transform.origin
	$Body.rotation.y = start_transform.basis.get_euler().y
	$Camera_Rig.rotation.y = start_transform.basis.get_euler().y
	inventory.initialize_inventory()


func _ready():
	#External signal connections
	GameManager.connect("initialize_player", self, "_on_GameManager_initialize_player")
	for gate in get_tree().get_nodes_in_group("gate"):
		gate.connect("player_entered_gate", self, "_on_player_entered_gate")
	
	#Local signals connections
	inventory.connect("equipped_items_changed", self, "_on_inventory_equipped_items_changed")
	
	###DEBUG?###
	Global.set_player(self)
	
	connect_motion_signals()


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


func _on_inventory_equipped_items_changed(equipped_items):
	emit_signal("equipped_items_changed", equipped_items)


###EXTERNAL SIGNAL FUNCS###
func _on_GameManager_initialize_player(start_transform : Transform):
	initialize(start_transform)


func _on_player_entered_gate(gate_node):
	emit_signal("player_entered_gate", gate_node)



