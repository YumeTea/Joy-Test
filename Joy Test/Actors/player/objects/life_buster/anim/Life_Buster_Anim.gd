extends Spatial


#signal animation_finished(anim_name)


onready var Anim_Player = $AnimationPlayer

func _ready():
	Anim_Player.play("charging")


#func animation_finished(anim_name):
#	emit_signal("animation_finished", anim_name)



















