extends Node


var scenes_main_folder = "res://Resources/DatabaseItems/Scenes_Main/"
var scenes_main : Array #A list of dicts for each spell


func _ready():
	#Fill database at start
	scenes_main = get_database_resources([scenes_main_folder])


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


func get_scene(scene_name):
	for s in scenes_main:
		if s.scene_name == scene_name:
			return s
	
	print("scene with scene_name " + scene_name + " not in SceneDatabase")
	return null












