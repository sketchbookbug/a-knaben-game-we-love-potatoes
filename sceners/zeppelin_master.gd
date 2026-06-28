extends Node2D

var IsometricRoomRoot = null

func _ready():
	IsometricRoomRoot = $IsometricRoomRoot
	
	IsometricRoomRoot.set_scene(0)
	
func _process(dt):
	pass
