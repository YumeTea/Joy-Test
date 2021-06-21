extends Node

'there is some situation where the aim state is exited when attacking even if holding aim_r'

'Figure out why in editor signal connections dont work for states'
'Aim states may be running 1 frame longer than intended'
'Input deadzones need to interpolate between deadzone bounds'
'Should store and retrieve certain controller values globally (gyro_sensitivity)'
'Is there a better way to preserve variables between states?'


'Buffer jab_aim input? or some other solution'


func ideas_aiming():
	'aim_r activates aim mode and holding aim_r while in aim mode allows for gyro control of the camera'
	'letting go of aim_r in aim mode only stops gyro input'
	'holding aim_r again in aim mode resumes gyro input'
	'this allows easy turn around during aim mode'
	
	'aim mode must be cancelled with the cancel input'
	
	
	pass


func ideas_targetting():
	'attacking while targetting (not aiming) should be robust to give it some reason to use over aiming'












































