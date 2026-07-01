extends Node2D

var current_item_id = 0
var current_item_name = ""

var allitemimages = {}

var description_parts = []
var ending_options = {}
var ending_option_flags = {}
var info_gains = []

var currently_looking_at_item = false


func InitializeItem(item_id):
	current_item_id = item_id
	currently_looking_at_item = true
	
	var item_data_file = FileAccess.open("item_data/" + str(item_id) + ".txt",FileAccess.READ)
	var item_data = item_data_file.get_as_text()
	var item_data_lines = item_data.split("\n",false)

	var currently_looking_at_ending_options = false
	var currently_looking_at_info_gains = false
	
	description_parts = []
	ending_options = {}
	ending_option_flags = {}
	
	var line_index = 0
	var init_id = -1
	var init_type = -1
	
	get_parent().find_child("ZeppelinMap").find_child("DoorIcon").hide()
	
	#print(dialogue_data_lines)
	
	for l in item_data_lines:
		
		#print("\n","we are charlie ",l)
		if l.replace(" ","")[0] == "#":		#comment line
			continue
			
		elif line_index == 0:	#data for item name
			
			if l.replace(" ","")[0] == "F":		#flag redirector
				
				var splitted = l.replace("/n","\n").lstrip("F").split(";",false)
				if splitted[0] in get_parent().flags:
					init_type = int(splitted[1])
					init_id = int(splitted[2])
					break
				
				continue
			
			else:
				current_item_name = l
				
		elif "[ENDDESC]" in l:	#now seeing ending options
			currently_looking_at_ending_options = true
			continue
			
		elif "[INFOGAINS]" in l:	#now seeing info gains
			currently_looking_at_info_gains = true
			currently_looking_at_ending_options = false
			continue
		
		elif currently_looking_at_info_gains:
			var splitted = l.split(";",false)
			info_gains.push_back([int(splitted[0]),int(splitted[1]),str(splitted[2]),bool(int(splitted[3]))])
			
		elif currently_looking_at_ending_options:
			var splitted = l.split(";",false)
			ending_options[splitted[0]] = 0
			if len(splitted) == 2:
				ending_option_flags[splitted[0]] = splitted[1].split(",",false)
			else:
				ending_option_flags[splitted[0]] = []
			
		else:
			#print("we have arrived here, my friend <", l)
			description_parts.push_back(l.replace("/n","\n"))
			
		line_index += 1
		
	$TalkyGuyImage.texture = allitemimages[current_item_name]
	$TalkyGuyImage.show()
	$NameLabel.text = current_item_name
		
	if init_id != -1:
		if init_type == 0:
			InitializeItem(init_id)
		elif init_type == 1:
			hide()
			$NameLabel.text = ""
			$MainText.text = ""
			$TalkyGuyImage.texture = null
			DeleteButtonChildren()
			currently_looking_at_item = false
			get_parent().find_child("DialogueMaster").show()
			get_parent().find_child("DialogueMaster").InitializeDialog(init_id)
		return
		
	else:
		NextDescriptionPoint()

func NextDescriptionPoint():
	if len(description_parts) == 0:	#failsave
		return
		
	#text
	var next_text = description_parts[0]
	description_parts.remove_at(0)
	
	$MainText.text = next_text
		
	#check if its the end
	if len(description_parts) == 0:
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
		current_button.text = ending_name
		current_button.set_position(Vector2(930,780-40*buttonindex))
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
		get_parent().current_fadeout_function = "ItemEnd"
		get_parent().find_child("FadeoutPolygon").visible = true
		get_parent().currently_zooming_out = true
	else:
		#aw sh*t here we go again
		DeleteButtonChildren()
		InitializeItem(ending_sender)
		$TalkyGuyImage.show()

func DeleteButtonChildren():
	$TalkyGuyImage.hide()
	$MainText.text = ""
	for child in self.get_children():
		if child is Button:
			child.hide()
			remove_child(child)

func _ready():
	
	#import all images for the characters
	var itemig_files = DirAccess.get_files_at("assets/items")
	for itemig_file in itemig_files:
		if len(itemig_file.split(".",false)) != 2:
			continue
			
		var local_itemimg_texture = load("assets/items/"+itemig_file)
		allitemimages[itemig_file.split(".",false)[0]] = local_itemimg_texture

func _process(dt):
	if self.visible:
		if Input.is_action_just_pressed("ForwardDialogue"):
			NextDescriptionPoint()
