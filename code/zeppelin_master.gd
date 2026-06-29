extends Node2D

var current_scene = 0
var background_images = {}
var room_names = {}

var currently_fading_out = false
var currently_fading_in = false
var total_fadeout_time = 0.8
var fadeout_alpha_steps_in_a_second = 2 / total_fadeout_time	#1 over half of the total fadeout time
var current_fadeout_function = ""
var current_scene_trans_id = 0
var current_scene_trans_child = null

func change_fadeout_time(val):
	total_fadeout_time = val
	fadeout_alpha_steps_in_a_second = 2 / val


func _ready():
	
	$FadeoutPolygon.self_modulate.a = 0
	$FadeoutPolygon.visible = false

	var background_files = DirAccess.get_files_at("assets/backgrounds")
	for bg_file in background_files:
		if len(bg_file.split(".",false)) != 2 or ".import" in bg_file:
			continue
			
		var local_bg_texture = load("assets/backgrounds/"+bg_file)
		background_images[int(bg_file.split(".",false)[0])] = local_bg_texture
		
	var room_name_file = FileAccess.open("zeppelin_data/room_ids_to_room_names.txt",FileAccess.READ)
	for room_name_line in room_name_file.get_as_text().split("\n",false):
		var splitted = room_name_line.replace("/n","\n").split(";",false)
		room_names[int(splitted[0])] = splitted[1]
	
	#change_scene($RoomViewRoot,0)
	#$DialogueMaster.hide()
	initiate_scene_set(0,$RoomViewRoot,"DoorTransition")
	
	
func _start_FadeIn():
	$FadeoutPolygon.self_modulate.a = 1
	currently_fading_out = false
	currently_fading_in = true
	
	match current_fadeout_function:
		"DoorTransition":
			change_scene(current_scene_trans_child,current_scene_trans_id)
		"Dialogue":
			$RoomViewRoot.visible = false
			for child in $ZeppelinMap.get_children():
				if child is Button:
					child.visible = false
			$DialogueMaster.InitializeDialog(current_scene_trans_id)
		"DialogueEnd":
			StartExistingAfterDialogue()
			#$DialogueMaster.hide()
			$DialogueMaster.DeleteButtonChildren()
			$DialogueMaster.currently_in_dialogue = false
			$DialogueMaster.find_child("NameLabel").text = ""
			if current_scene in room_names.keys():
				$DialogueMaster.find_child("NameLabel").text = room_names[current_scene]
			
func StartExistingAfterDialogue():
	$RoomViewRoot.visible = true
	$ZeppelinMap.visible = true
	for child in $ZeppelinMap.get_children():
		child.visible = true
	
func _stop_Fadestuff():
	currently_fading_in = false
	currently_fading_out = false
	$FadeoutPolygon.self_modulate.a = 0
	$FadeoutPolygon.visible = false
	
func initiate_scene_set(id,child,scene_type):
	currently_fading_in = false
	currently_fading_out = true
	current_scene_trans_id = id
	current_scene_trans_child = child
	current_fadeout_function = scene_type
	
	$FadeoutPolygon.visible = true
	
func change_scene(child,id):
	if child == $RoomViewRoot:
		$ZeppelinMap.set_scene(1000+id)
		current_scene = id
		child.set_scene(id)
	elif child == $ZeppelinMap:
		$RoomViewRoot.set_scene(id-1000)
		current_scene = id - 1000
		child.set_scene(id)
		
	#change background
	#print(id,background_images)
	if current_scene in background_images.keys():
		$Background.texture = background_images[current_scene]
		
	if current_scene in room_names.keys():
		$DialogueMaster.find_child("NameLabel").text = room_names[current_scene]
		#print("Entering ", room_names[current_scene])
	
func _process(dt):
	if currently_fading_out:
		$FadeoutPolygon.self_modulate.a += fadeout_alpha_steps_in_a_second * dt
		if $FadeoutPolygon.self_modulate.a >= 1:
			self._start_FadeIn()
	elif currently_fading_in:
		$FadeoutPolygon.self_modulate.a -= fadeout_alpha_steps_in_a_second * dt
		if $FadeoutPolygon.self_modulate.a <= 0:
			self._stop_Fadestuff()
