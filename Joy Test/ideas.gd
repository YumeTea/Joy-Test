extends Node



'Figure out why in editor signal connections dont work for states'
'Aim states may be running 1 frame longer than intended'


'What inputs should be buffered?'


func ideas_targetting():
	'attacking while targetting (not aiming) should be robust to give it some reason to use over aiming'


func ideas_projectiles():
	'have projectile group'
	'check for collision with projectile on player when moving'
	'if collision with projectile, call projectile impact() method with player as argument'
	'move player rest of way'


###QUIRKS###
'anims meant to play once currently need code to play the none animation when they are done'
'i.e. anims in animtree will infinitely play their last frame unless the playback is stopped'







































