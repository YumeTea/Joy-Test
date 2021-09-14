extends Node


var spells_folder = "res://Resources/DatabaseItems/Spells"
var spells : Array #A list of dicts for each spell


func _ready():
	spells = get_database_resources([spells_folder])

func get_database_resources(resource_folders : Array):
	var resources : Array
	
	for folder in resource_folders:
		var directory = Directory.new()
		directory.open(folder)
		directory.list_dir_begin()
		
		var file = directory.get_next()
		while(file):
			if not directory.current_is_dir():
				resources.append(load(folder + "/%s" % file))
		
			file = directory.get_next()
	
	return resources


func get_spell(spell_name):
	for s in spells:
		if s.name == spell_name:
			return s
	
	return null












