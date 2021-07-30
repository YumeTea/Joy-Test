extends Resource
class_name Inventory


'Ready function does not run for this script'


signal inventory_changed(inventory_resource)
signal equipped_items_changed(equipped_items)

#export var _items = Array() setget set_items, get_items
export var equipped_items = { #Contains equipped items on player
	"Spell": null,
}
export var inventory = { #Contains all items in player inventory
	"Spell": [],
}


func _ready():
	###DEBUG###
	debug_initialize_inventory()
	
	emit_signal("equipped_items_changed", equipped_items)


#func set_items(new_items):
#	_items = new_items
#	emit_signal("inventory_changed", self)
#
#
#func get_items():
#	return _items


func add_item(item_type, item_name):
	var item : Resource
	
	match item_type:
		"Spell":
			#Get spell from spell database
			item = SpellDatabase.get_spell(item_name)
			if not item: #if null returned, meaning spell not found in database
				print("Tried to add invalid spell to inventory")
				return
	
	if !(item in inventory[item_type]):
		inventory[item_type].append(item)


#item.name may cause issues???
func remove_item(item_type, item_name):
	#If item is equipped, remove from equipped items
	
	#Remove item from inventory
	for i in inventory[item_type]:
		if i.name == item_name:
			inventory[item_type].remove(inventory[item_type].find(i))
			return
	
	


func equip_item(item_type, item_name):
	if item_name != null:
		for i in inventory[item_type]:
			if i.name == item_name:
				equipped_items[item_type] = i
				emit_signal("equipped_items_changed", equipped_items)
				return
		#Item not in inventory pring
		print("Item to equip not found in inventory")
	else:
		equipped_items[item_type] = null
		emit_signal("equipped_items_changed", equipped_items)


###DEBUG FUNCTIONS###
func debug_initialize_inventory():
	add_item("Spell", "Life_Buster")
	add_item("Spell", "Barrier")
	equip_item("Spell", "Life_Buster")























