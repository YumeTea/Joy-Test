extends Node


var spells_folder = "res://Resources/DatabaseItems/Spells/"
var spells : Array #A list of dicts for each spell


func _ready():
	var directory = Directory.new()
	directory.open(spells_folder)
	directory.lis_dir_begin()
	
	var file = directory.get_next()
	while(file):
		if not directory.current_is_dir():
			spells.append(load(spells_folder + "/s" % file))
	
		file = directory.get_next()
	


func get_spell(spell_name):
	for s in spells:
		if s.name == spell_name:
			return s
	
	return null












