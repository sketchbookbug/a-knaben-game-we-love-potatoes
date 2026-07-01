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

var currently_zooming_in = false
var currently_zooming_out = false
var current_zoomout_focus = Vector2(0.0,0.0)
var total_zoomin_movement = Vector2(0.0,0.0)
var zoomin_movement_in_a_second = Vector2(0.0,0.0)
var total_zoomsteps_in_a_second = fadeout_alpha_steps_in_a_second * 0.25 * 2	#zoomin to 1.25

var flags = []

func change_fadeout_time(val):
	total_fadeout_time = val
	fadeout_alpha_steps_in_a_second = 2 / val
	
func calculate_zoomin_stuff_for_bg():
	total_zoomin_movement.x = (705-current_zoomout_focus.x) * 1.25
	total_zoomin_movement.y = (542-current_zoomout_focus.y) * 1.25
	zoomin_movement_in_a_second.x = 0#total_zoomin_movement.x / (total_fadeout_time * 0.5)
	zoomin_movement_in_a_second.y = 0#total_zoomin_movement.y / (total_fadeout_time * 0.5)

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
	_start_FadeIn()
	
	
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
			$InteractableMaster.hide()
			$DialogueMaster.InitializeDialog(current_scene_trans_id)
		"Item":
			$RoomViewRoot.visible = false
			for child in $ZeppelinMap.get_children():
				if child is Button:
					child.visible = false
			$DialogueMaster.hide()
			$InteractableMaster.InitializeItem(current_scene_trans_id)
			currently_zooming_in = false
			$Background.scale = Vector2(1.25,1.25)
			$InteractableMaster/TalkyGuyImage.self_modulate.a = 1
		"DialogueEnd":
			StartExistingAfterDialogue()
			#$DialogueMaster.hide()
			$DialogueMaster.DeleteButtonChildren()
			$DialogueMaster.currently_in_dialogue = false
			$DialogueMaster.find_child("NameLabel").text = ""
			if current_scene in room_names.keys():
				$DialogueMaster.find_child("NameLabel").text = room_names[current_scene]
			if current_scene != 9:	#not in lounge -> should show door icon again
				$ZeppelinMap/DoorIcon.show()
			$InteractableMaster.show()
		"ItemEnd":
			StartExistingAfterDialogue()
			$InteractableMaster.hide()
			$InteractableMaster.DeleteButtonChildren()
			$InteractableMaster.currently_looking_at_item = false
			$DialogueMaster.show()
			currently_zooming_out = false
			$Background.scale = Vector2(1.0,1.0)
		"CutsceneStart":
			$CutsceneMaster.StartCutscene(current_scene_trans_id)
		"CutsceneNext":
			$CutsceneMaster.NextCutscenePoint()
		"CutsceneEnd":
			$CutsceneMaster.hide()
			$CutsceneMaster.currently_playing_cutscene = false
			
			
func StartExistingAfterDialogue():
	$RoomViewRoot.visible = true
	$ZeppelinMap.visible = true
	for child in $ZeppelinMap.get_children():
		child.visible = true
	
func _stop_Fadestuff():
	currently_fading_in = false
	currently_fading_out = false
	currently_zooming_in = false
	currently_zooming_out = false
	$FadeoutPolygon.self_modulate.a = 0
	$FadeoutPolygon.visible = false
	
func initiate_scene_set(id,child,scene_type,interactable_pos=Vector2(0.0,0.0)):
	currently_fading_in = false
	currently_fading_out = true
	current_scene_trans_id = id
	current_scene_trans_child = child
	current_fadeout_function = scene_type
	if scene_type == "Item":
		currently_zooming_in = true
		current_zoomout_focus = interactable_pos
		calculate_zoomin_stuff_for_bg()
	elif scene_type == "ItemEnd":
		currently_zooming_out = true
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
	#print(flags)
	if Input.is_key_pressed(KEY_F1):
		$JournalMaster.OpenThyself()
	if Input.is_key_pressed(KEY_F2):
		$JournalMaster.CloseThyself()
	if currently_fading_out:
		$FadeoutPolygon.self_modulate.a += fadeout_alpha_steps_in_a_second * dt
		if current_fadeout_function == "CutsceneStart":
			$CutsceneMaster/BackBackground.self_modulate.a += fadeout_alpha_steps_in_a_second * dt
		if $FadeoutPolygon.self_modulate.a >= 1:
			self._start_FadeIn()
	elif currently_fading_in:
		$FadeoutPolygon.self_modulate.a -= fadeout_alpha_steps_in_a_second * dt
		if $FadeoutPolygon.self_modulate.a <= 0:
			self._stop_Fadestuff()
	if currently_zooming_in:
		$Background.scale.x += total_zoomsteps_in_a_second * dt
		$Background.scale.y += total_zoomsteps_in_a_second * dt
		$Background.global_position.x -= zoomin_movement_in_a_second.x * dt
		$Background.global_position.y -= zoomin_movement_in_a_second.y * dt
	elif currently_zooming_out:
		$Background.scale.x -= total_zoomsteps_in_a_second * dt
		$Background.scale.y -= total_zoomsteps_in_a_second * dt
		$Background.global_position.x += zoomin_movement_in_a_second.x * dt
		$Background.global_position.y += zoomin_movement_in_a_second.y * dt
		$InteractableMaster/TalkyGuyImage.self_modulate.a -= fadeout_alpha_steps_in_a_second * dt * 2
