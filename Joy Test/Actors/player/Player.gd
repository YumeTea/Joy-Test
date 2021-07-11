extends KinematicBody


#Inventory Variables
const inventory_resource = preload("res://Resources/CustomResources/inventory_resource.gd")
var inventory = inventory_resource.new()


func _ready():
	self.inventory.debug_initialize_inventory()























