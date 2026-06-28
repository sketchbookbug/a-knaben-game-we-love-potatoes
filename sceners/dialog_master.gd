extends Node2D

var current_dialog_id = 0
var current_talky_guy = ""
var current_dialog_point = 0
var allcharimages = {}
var dialogue_image_queue = []

func InitializeDialog(dialog_id):
	current_dialog_id = dialog_id
	self.show()
	
	var dialogue_data_file = FileAccess.open("dialogue_data/" + str(dialog_id) + ".txt",FileAccess.READ)
	var dialogue_data = dialogue_data_file.get_as_text()
	var dialogue_data_lines = dialogue_data.split("\n",false)
	
	var dialogue_parts = []
	var dialogue_image_name_queue = []
	var ending_options = {}
	var currently_looking_at_ending_options = false
	
	var line_index = 0
	
	for l in dialogue_data_lines:
		if l.replace(" ","")[0] == "#":		#comment line
			dialogue_data_lines.remove_at(line_index)
			continue
			
		elif line_index == 0:	#data for who we are talking to
			current_talky_guy = l
			
		elif currently_looking_at_ending_options:
			var splitted = l.split(";",false)
			ending_options[splitted[1]] = int(splitted[0])
			
		else:
			if "[ENDCONVO]" in l:	#now seeing ending options
				currently_looking_at_ending_options = true
				continue
				
			var splitted = l.split(";",false)
			dialogue_image_name_queue.push_back(current_talky_guy + "_" + splitted[0])	#the expression of the talky guy so we can later get the image of them
			dialogue_parts.push_back(splitted[1].replace("/n","\n"))
			
		line_index += 1
	
	#prepare dialogue images
	dialogue_image_queue.clear()
	for dialogue_image_name in dialogue_image_name_queue:
		if dialogue_image_name in allcharimages.keys():
			dialogue_image_queue.push_back(allcharimages[dialogue_image_name])
		else:
			dialogue_image_queue.push_back(allcharimages["1_1"])
		
	$DialogueTextManager.load_text(dialogue_parts)
	


func _ready():
	
	#import all images for the characters
	var charimg_files = DirAccess.get_files_at("assets/characters")
	for charimg_file in charimg_files:
		if len(charimg_file.split(".",false)) != 2:
			continue
			
		var local_charimg_texture = load("assets/characters/"+charimg_file)
		allcharimages[charimg_file.split(".",false)[0]] = local_charimg_texture
		
	
func _process(dt):
	pass
