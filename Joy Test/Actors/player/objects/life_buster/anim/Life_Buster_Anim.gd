extends Spatial

onready var Anim_Player = $AnimationPlayer

func _ready():
	Anim_Player.play("Cast_Life_Buster")

