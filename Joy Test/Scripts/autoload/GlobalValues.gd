extends Node


var collision_material_groups = []

var collision_materials_soft = [
	"wood",
	"debug_soft",
]

var collision_materials_loose = [
	"debug_loose",
]

var collision_materials_solid = [
	"metal",
	"debug_solid",
]


func _ready():
	collision_material_groups = collision_materials_soft + collision_materials_loose + collision_materials_solid

