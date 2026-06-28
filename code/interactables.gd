extends Node2D

func set_scene(scene_id=0):
	
	for child in get_children():
		self.remove_child(child)
		
	var interactable_data_file = FileAccess.open("zeppelin_interactables_data/" + str(scene_id) + ".txt",FileAccess.READ)
	var interactable_data = interactable_data_file.get_as_text()
	
	var dialogue_data_file = FileAccess.open("zeppelin_dialogue_data/" + str(scene_id) + ".txt",FileAccess.READ)
	var dialogue_data = dialogue_data_file.get_as_text()
	
	for interactable_dataset in interactable_data.split("\n",false):
		var splitted = interactable_dataset.split(",",false)
		print(splitted)
		
		if len(splitted) == 4:
			splitted.push_back("50")
			splitted.push_back("50")
		
		if len(splitted) != 6:
			print("Interactable data seems to be non-correct: ")
			print(interactable_dataset)
			continue
		
		var pos = Vector2(int(splitted[2]),int(splitted[3]))
		var size = Vector2(int(splitted[4]),int(splitted[5]))
		create_interactable(int(splitted[0]),int(splitted[1]),pos,size)

func create_interactable(create_type=0,send_id=0,button_position=Vector2(0,0),button_size=Vector2(50,50)):
	var current_button = Button.new()
	current_button.set_meta("create_type",create_type)
	current_button.set_meta("send_id",send_id)
	current_button.set_position(button_position)
	current_button.set_size(button_size)
	current_button.self_modulate.a = 0+100
	var lambda = func local_lambda(): button_pressed(current_button)
	current_button.pressed.connect(lambda)
	add_child(current_button)
	
func button_pressed(cb):
	var create_type = cb.get_meta("create_type")
	var send_id = cb.get_meta("send_id")
	
	#var create_type = cb.get_meta("create_type")
	match create_type:
		0:	#interactable (clue, ...)
			pass
		1:	#dialogue
			pass
		2:	#scene changer (door, ...)
			#play some noise or smth
			set_scene(send_id)

func _ready():
	set_scene(0)
	
func _process(dt):
	pass
