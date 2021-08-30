extends Resource
class_name Spell

export var name : String
export var index : int

export var item_type = "Spell"
export (String, "projectile", "barrier", "held_affect") var spell_type
export var alt_cast : bool
export (String, FILE) var player_cast_anim
export (String, FILE) var object_scene
export (String, FILE) var object_charging_scene




















