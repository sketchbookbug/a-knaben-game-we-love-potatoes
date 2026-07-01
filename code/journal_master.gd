extends Node2D

var current_page = 0
var accessible_pages = [1,2,3,4,5]

var ids_to_names_and_profession = {}
var names_to_id = {}
var notes_about_em_by_id = {}
var notes_from_em_by_id = {}
var secured_non_murderer = {}

var allcharimages = {}

#temp info
var current_name_and_profession = ["",""]
var notes_about_current_person = []
var notes_from_current_person = []
var could_be_it = false
var current_char_img = null
var about_text = ""
var from_text = ""

func OpenThyself(id_to_open_to=1):
	#play the opening animation
	
	#flip to given page
	ComputeNewPage(id_to_open_to,false)
	
	UpdateArrowSprites()
		
	#do this in the middle of the opening anim
	DisplayInfo()
	
func CloseThyself():
	hide()
	#play the opening animation in reverse

func ComputeNewPage(new_id,show_page_flip_anim=true):
	var old_id = current_page
	current_page = new_id
	
	#get all the information
	current_name_and_profession = ids_to_names_and_profession[current_page]
	notes_about_current_person = notes_about_em_by_id[current_page]
	notes_from_current_person = notes_from_em_by_id[current_page]
	could_be_it = not secured_non_murderer[current_page]
	
	current_char_img = allcharimages[str(new_id) + "_" + "0"]
	
	#prepare displayable infos
	about_text = "INFORMATION ABOUT THEM: \n"
	for info in notes_about_current_person:
		about_text += " - " + info + "\n"
		
	from_text = "INFORMATION FROM THEM: \n"
	for info in notes_from_current_person:
		from_text += " - " + info + "\n"
		
	if show_page_flip_anim:		#show the animation of the page flipping (if new_id is smaller than old_id, then left; otherwise right)
		pass
	
	
func DisplayInfo():
	show()
	#display that information
	$NameLabel.text = current_name_and_profession[0]
	$ProfessionLabel.text = "Profession: " + current_name_and_profession[1]
	$InfoFromLabel.text = from_text
	$InfoAboutLabel.text = about_text
	if could_be_it:
		$CanBeLabel.text = "COULD BE THE MURDERER?"
	else:
		$CanBeLabel.text = "SECURED NOT GUILTY"

func AddInfo(info,type_of_info,subject_id,loud=false):
	match type_of_info:
		"FROM":
			notes_from_em_by_id[subject_id].push_back(info)
		1:
			notes_from_em_by_id[subject_id].push_back(info)
		"ABOUT":
			notes_about_em_by_id[subject_id].push_back(info)
		0:
			notes_about_em_by_id[subject_id].push_back(info)
		"SECUREDNONMURDERER":
			secured_non_murderer[subject_id] = bool(info)
		2:
			secured_non_murderer[subject_id] = bool(info)
	
	if loud:
		ComputeNewPage(subject_id,true)
	elif current_page == subject_id:
		ComputeNewPage(subject_id,false)
		DisplayInfo()



func _ready():
	#get the names + professions for the characters
	var speaker_name_file = FileAccess.open("dialogue_data/speaker_ids_to_names.txt",FileAccess.READ)
	var speaker_name_lines = speaker_name_file.get_as_text().split("\n",false)
	for speaker_name_line in speaker_name_lines:
		var splitted = speaker_name_line.split(";")
		ids_to_names_and_profession[int(splitted[0])] = [splitted[1].replace("/n","\n"),splitted[2].replace("/n","\n")]
		names_to_id[splitted[2].replace("/n","\n")] = int(splitted[0])
		
	#import all images for the characters
	var charimg_folders = DirAccess.get_directories_at("assets/characters")
	for charimg_folder in charimg_folders:
		#if charimg_folder not in ids_to_names_and_profession.keys():
		#	continue
			
			
		var current_char_id = names_to_id[charimg_folder]
		var charimg_files = DirAccess.get_files_at("assets/characters/" + charimg_folder + "/")
		var charimg_index = 0
		
		for charimg_file in charimg_files:
			if len(charimg_file.split(".",false)) != 2:
				continue
			
			var local_charimg_texture = load("assets/characters/"+ charimg_folder + "/" + charimg_file)
			allcharimages[str(current_char_id)+"_"+str(charimg_index)] = local_charimg_texture
			charimg_index += 1
			
	#fill stuff with empty data
	for i in range(5):
		notes_about_em_by_id[i+1] = []
		notes_from_em_by_id[i+1] = []
		secured_non_murderer[i+1] = false
		
	$FlipLeftButton.connect("button_down",TrytoFlipOnePageLeft)	
	$FlipRightButton.connect("button_down",TrytoFlipOnePageRight)	
		
		
func TrytoFlipOnePageLeft():
	var new_page_to_flip_to = current_page - 1
	if new_page_to_flip_to in accessible_pages:
		ComputeNewPage(new_page_to_flip_to)
		DisplayInfo()
	UpdateArrowSprites()
		
func TrytoFlipOnePageRight():
	var new_page_to_flip_to = current_page + 1
	if new_page_to_flip_to in accessible_pages:
		ComputeNewPage(new_page_to_flip_to)
		
		#instead, await stuff; this is only temporary
		DisplayInfo()
	UpdateArrowSprites()
	
func UpdateArrowSprites():
	if current_page == accessible_pages[-1]:
		$RightArrowSprite.hide()
	else:
		$RightArrowSprite.show()
		
	if current_page == accessible_pages[0]:
		$LeftArrowSprite.hide()
	else:
		$LeftArrowSprite.show()
	
func _process(dt):
	if visible:	#and not animation being played
		#if left key or a is pressed, go back one page, except you cant
		if Input.is_action_just_pressed("JournalLeft"):
			TrytoFlipOnePageLeft()
			
		#if right key or d is pressed, go forward one page, except you cant
		elif Input.is_action_just_pressed("JournalRight"):
			TrytoFlipOnePageRight()
