tool
extends EditorScenePostImport

var scene_root_name = "Body"

var CHAR_MODEL_SAVE_PATH = "res://Actors/player/model/Player_Model.tscn"
var ANIM_IMPORT_FOLDER = "res://Actors/player/model/anim/anim_import_new/"
var ANIM_FOLDER = "res://Actors/player/model/anim/anim_boneform/"

#Materials
var material_01 = preload("res://Actors/player/model/BoneForm/materials/default_material.tres")


func post_import(scene):
	scene.set_name(scene_root_name)
	
	###ROTATION/SCALE CORRECTION
	scene.get_node("Armature/Skeleton").rotate_y(deg2rad(180))
	
	###MATERIAL APPLICATION###
	for child in scene.get_node("Armature/Skeleton").get_children():
		if child is MeshInstance:
			child.set_surface_material(0, material_01)
	
	###ANIMATIONS###
	#Clear anim import folder
	var dir_anim_import : Directory = Directory.new()
	
	if dir_anim_import.open(ANIM_IMPORT_FOLDER) == OK:
		dir_anim_import.list_dir_begin(true)
		var file_name = dir_anim_import.get_next()
		while file_name != "": #empty string is returned once dir data stream has been completed
			dir_anim_import.remove(file_name)
			file_name = dir_anim_import.get_next() #Gets the next element (file or dir) from the directory data stream
	else:
		print("An error occurred when trying to access %s" % ANIM_IMPORT_FOLDER)
	
	#Iterate through imported anims, replacing the tracks of existing anims on Godot side
	for anim in scene.get_node("AnimationPlayer").get_animation_list():
		var anim_found = false
		
		var anim_resource = scene.get_node("AnimationPlayer").get_animation(anim)
		anim_resource.step = 0.0166666 #change FPS to 60
#		anim_resource.loop = true
		
		#Modify track paths of animation
		for track_idx in anim_resource.get_track_count():
			var track_path = anim_resource.track_get_path(track_idx)
			track_path = scene_root_name + "/" + track_path
			anim_resource.track_set_path(track_idx, track_path)
		
		#Check if anim is already present, replace tracks if so, else put anim in temp import folder
		var directory_anim : Directory = Directory.new()
		
		if directory_anim.open(ANIM_FOLDER) == OK:
			directory_anim.list_dir_begin(true)
			var file_name = directory_anim.get_next()
			while file_name != "":
				if file_name == "%s.anim" % anim:
					var anim_saved = load(ANIM_FOLDER.plus_file(file_name)) #load found anim to replace tracks
					
					#Replace same tracks from new anim to saved anim
					for track in anim_resource.get_track_count():
						anim_saved.remove_track(anim_saved.find_track(anim_resource.track_get_path(track)))
						anim_resource.copy_track(track, anim_saved)
					
					#Save modified anim
					var save_path = ANIM_FOLDER.plus_file("%s.anim" % anim)
					
					var error : int = ResourceSaver.save(ANIM_FOLDER.plus_file(file_name), anim_saved)
					if error != OK:
						print("error saving anim in import_boneform.gd")
					anim_found = true
					break
				
				file_name = directory_anim.get_next()
		
		#Save anim in temp anim folder if it wasn't found on player anim player
		if !anim_found:
			var save_path = ANIM_IMPORT_FOLDER.plus_file("%s.anim" % anim)
			
			var error : int = ResourceSaver.save(save_path, anim_resource)
			if error != OK:
				print("error saving anim in nikki_import.gd")
	
	#Delete AnimationPlayer
	scene.get_node("AnimationPlayer").free()
	
	###SCENE SAVING###
	#Save character model scene
	var scene_resource = PackedScene.new()
	
	var result = scene_resource.pack(scene)
	if result == OK:
		var error : int = ResourceSaver.save(CHAR_MODEL_SAVE_PATH, scene_resource)
		if error != OK:
			print("error saving %s" % scene.name)
	
	
	
	return scene






















