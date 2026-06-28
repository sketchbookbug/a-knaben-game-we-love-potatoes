extends Node2D

var RoomViewRoot = null
var ZeppelinMap = null

func _ready():
	
	$RoomViewRoot.set_scene(0)
	$ZeppelinMap.set_scene(1000)
	
#for better fadeout stuff
func initiate_scene_set(id,child):
	print(id,child)
	if child == $RoomViewRoot:
		$ZeppelinMap.set_scene(1000+id)
		child.set_scene(id)
	elif child == $ZeppelinMap:
		$RoomViewRoot.set_scene(id-1000)
		child.set_scene(id)
	
func _process(dt):
	pass
