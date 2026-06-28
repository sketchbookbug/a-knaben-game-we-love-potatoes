extends Node2D

func InitializeDialog(dialog_id):
	print(dialog_id)
	get_parent().find_child("RoomViewRoot").hide()
	for child in get_parent().find_child("RoomViewRoot").get_children():
		child.hide()


func _ready():
	pass
	
func _process(dt):
	pass
