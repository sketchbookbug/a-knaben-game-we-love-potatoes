extends Node2D

var current_dialog_id = 0
var current_talky_guy = ""

var allcharimages = {}
var allcharimageypositions = {}
var dialogue_image_queue = []

var dialogue_parts = []
var ending_options = {}
var ending_option_flags = {}
var info_gains = []

var talky_guy_names_by_id = {}
var talky_guy_ids_by_names = {}
var currently_in_dialogue = false


func InitializeDialog(dialog_id):
	current_dialog_id = dialog_id
	currently_in_dialogue = true
	
	var dialogue_data_file = FileAccess.open("dialogue_data/" + str(dialog_id) + ".txt",FileAccess.READ)
	var dialogue_data = dialogue_data_file.get_as_text()
	var dialogue_data_lines = dialogue_data.split("\n",false)

	var currently_looking_at_ending_options = false
	var currently_looking_at_info_gains = false
	
	dialogue_parts = []
	ending_options = {}
	ending_option_flags = {}
	
	var line_index = 0
	var init_dialogue_id = -1
	
	get_parent().find_child("ZeppelinMap").find_child("DoorIcon").hide()
	
	#print(dialogue_data_lines)
	
	for l in dialogue_data_lines:
		
		#print("\n","we are charlie ",l)
		if l.replace(" ","")[0] == "#":		#comment line
			continue
			
		elif line_index == 0:	#data for who we are talking to
			
			if l.replace(" ","")[0] == "F":		#flag redirector
				
				var splitted = l.replace("/n","\n").lstrip("F").split(";",false)
				if splitted[0] in get_parent().flags:
					init_dialogue_id = int(splitted[1])
					break
				
				continue
			
			else:
				current_talky_guy = l
				
		elif "[ENDCONVO]" in l:	#now seeing ending options
			currently_looking_at_ending_options = true
			continue
			
		elif "[INFOGAINS]" in l:#now seeing info gains
			currently_looking_at_info_gains = true
			currently_looking_at_ending_options = false
			continue
				
		elif currently_looking_at_info_gains:
			var splitted = l.split(";",false)
			info_gains.push_back([int(splitted[0]),int(splitted[1]),str(splitted[2]),bool(int(splitted[3]))])
			
		elif currently_looking_at_ending_options:
			var splitted = l.split(";",false)
			ending_options[splitted[1]] = int(splitted[0])
			if len(splitted) == 3:
				ending_option_flags[splitted[1]] = splitted[2].split(",",false)
			else:
				ending_option_flags[splitted[1]] = []
			
		else:
			#print("we have arrived here, my friend <", l)
			var splitted = l.split(";",false)
			dialogue_image_queue.push_back(current_talky_guy + "_" + splitted[0])	#the expression of the talky guy so we can later get the image of them
			dialogue_parts.push_back(splitted[1])
			
		line_index += 1
		
		
	$TalkyGuyImage.show()
		
	if init_dialogue_id != -1:
		InitializeDialog(init_dialogue_id)
		return
		
	else:
		
		NextDialogPoint()

func NextDialogPoint():
	if len(dialogue_parts) == 0:	#failsave
		return
		
	#text
	var next_text = dialogue_parts[0]
	dialogue_parts.remove_at(0)
	
	$MainText.text = next_text
	
	#image
	var next_image_name = dialogue_image_queue[0]
	dialogue_image_queue.remove_at(0)
	
	var next_image = null
	if next_image_name in allcharimages.keys():
		next_image = allcharimages[next_image_name]
		
	$TalkyGuyImage.texture = next_image
	$TalkyGuyImage.global_position.y = allcharimageypositions[next_image]
	
	#character name
	var current_speaker_name = talky_guy_names_by_id[current_talky_guy]
	$NameLabel.text = current_speaker_name
		
	#check if its the end
	if len(dialogue_parts) == 0:
		DisplayEndingOptions()
	
func DisplayEndingOptions():
	var buttonindex = 0
	for ending_name in ending_options.keys():
		var ending_sender = ending_options[ending_name]
		
		var current_button = Button.new()
		current_button.set_meta("ending_sender",ending_sender)
		current_button.set_meta("ending_flags",ending_option_flags[ending_name])
		current_button.set_size(Vector2(200,30))
		current_button.z_as_relative = false
		current_button.z_index = 99
		current_button.text = ending_name.replace("/n","\n")
		current_button.set_position(Vector2(880,750-70*buttonindex))
		var lambda = func local_lambda(): SendOnButtonPress(current_button)
		current_button.pressed.connect(lambda)
		add_child(current_button)
		buttonindex += 1
		
func SendOnButtonPress(pressed_button):
	var ending_sender = pressed_button.get_meta("ending_sender")
	for flag in pressed_button.get_meta("ending_flags"):
		get_parent().flags.append(flag)
	if ending_sender == 0:
		#end dialogue existence and get back to normal view
		get_parent().currently_fading_out = true
		get_parent().current_fadeout_function = "DialogueEnd"
		get_parent().find_child("FadeoutPolygon").visible = true
	else:
		#aw sh*t here we go again
		DeleteButtonChildren()
		InitializeDialog(ending_sender)
		$TalkyGuyImage.show()

func DeleteButtonChildren():
	$TalkyGuyImage.hide()
	$MainText.text = ""
	for child in self.get_children():
		if child is Button:
			child.hide()
			remove_child(child)

func _ready():
	
	#get the names for the speakers
	var speaker_name_file = FileAccess.open("dialogue_data/speaker_ids_to_names.txt",FileAccess.READ)
	var speaker_name_lines = speaker_name_file.get_as_text().split("\n",false)
	for speaker_name_line in speaker_name_lines:
		var splitted = speaker_name_line.split(";")
		var character_name = splitted[1].replace("/n","\n")
		talky_guy_names_by_id[splitted[0]] = character_name
		talky_guy_ids_by_names[splitted[2].replace("/n","\n")] = splitted[0]
	
	#import all images for the characters
	var charimg_folders = DirAccess.get_directories_at("assets/characters")
	for charimg_folder in charimg_folders:
		if charimg_folder not in talky_guy_ids_by_names.keys():
			continue
			
		var current_char_id = talky_guy_ids_by_names[charimg_folder]
		var charimg_files = DirAccess.get_files_at("assets/characters/" + charimg_folder + "/")
		var charimg_index = 0
		
		for charimg_file in charimg_files:
			if len(charimg_file.split(".",false)) != 2:
				continue
			
			var local_charimg_texture = load("assets/characters/"+ charimg_folder + "/" + charimg_file)
			allcharimages[str(current_char_id)+"_"+str(charimg_index)] = local_charimg_texture
			allcharimageypositions[local_charimg_texture] = 800 - int(local_charimg_texture.get_image().get_height() * 0.5 * 0.5)	#2nd * 0.5 bcs we scale em down to 0.5x scale anyways
			charimg_index += 1
	
	
	
#	var charimg_files = DirAccess.get_("assets/characters")
#	for charimg_file in charimg_files:
#		print(charimg_file)
#		if len(charimg_file.split(".",false)) != 2:
#			continue
#			
#		var local_charimg_texture = load("assets/characters/"+charimg_file)
#		allcharimages[charimg_file.split(".",false)[0]] = local_charimg_texture
#		allcharimageypositions[local_charimg_texture] = 800 - int(local_charimg_texture.get_image().get_height() * 0.5)

func _process(dt):
	if self.visible:
		if Input.is_action_just_pressed("ForwardDialogue"):
			NextDialogPoint()
