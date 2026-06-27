extends Node2D

#create types:
#0 = interactable (clue, ...)
#1 = dialogue
#2 = scene changer (door, ...)

func create_interactable(create_type=0,send_id=0,button_position=Vector2(0,0),button_size=Vector2(50,50)):
	var current_button = Button.new()
	current_button.set_meta("create_type",create_type)
	current_button.set_meta("send_id",send_id)
	current_button.set_position(button_position)
	current_button.set_size(button_size)
	current_button.self_modulate.a = 0
	var lambda = func local_lambda(): button_pressed(current_button)
	current_button.pressed.connect(lambda)
	add_child(current_button)
	
func button_pressed(cb):
	var create_type = cb.get_meta("create_type")
	var send_id = cb.get_meta("send_id")
	
	#var create_type = cb.get_meta("create_type")
	match create_type:
		0:	#interactable (clue, ...)
			print(send_id)
		1:	#dialogue
			pass
		2:	#scene changer (door, ...)
			pass

func _ready():
	create_interactable(0,69,Vector2(0,0))
	
func _process(dt):
	pass
