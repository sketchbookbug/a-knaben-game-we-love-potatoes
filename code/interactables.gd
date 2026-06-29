extends Node2D

func set_scene(scene_id=0):
	for child in get_children():
		#if child is not TextureRect and child is not Container:
		if child is Button:
			child.hide()
			child.free()
	
	print("loading scene ", scene_id)
	var interactable_data_file = FileAccess.open("zeppelin_interactables_data/" + str(scene_id) + ".txt",FileAccess.READ)
	var interactable_data = interactable_data_file.get_as_text()
	
	for interactable_dataset in interactable_data.split("\n",false):
		if "#" in interactable_dataset:
			continue	#commentary line
			
		var splitted = interactable_dataset.split(",",false)
		
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
	if name == "ZeppelinMap":
		current_button.self_modulate.a = 0
	else:
		current_button.self_modulate.a = 1
	current_button.z_as_relative = false
	current_button.z_index = 99
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
			get_parent().initiate_scene_set(send_id,self,"Dialogue")
		2:	#scene changer (door, ...)
			get_parent().initiate_scene_set(send_id,self,"DoorTransition")

func _ready():
	#set_scene(0)
	pass
	
func _process(dt):
	pass#print("child count of ", self, " : ", get_child_count())
