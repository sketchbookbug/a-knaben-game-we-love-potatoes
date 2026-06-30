extends Node

var current_cutscene = ""
var currently_playing_cutscene = false

var all_cutscene_images = {}

var cutscene_text = {}
var cutscene_images = {}
var cutscene_fadeouts = {}

var current_cutscene_text = []
var current_cutscene_images = []
var current_cutscene_fadeouts = []

var current_waittime_left = 0


func StartCutscene(cutscene_name):
	
	#prepare current cutscene stuff
	current_cutscene_text = cutscene_text[str(cutscene_name)]
	current_cutscene_images = cutscene_images[str(cutscene_name)]
	current_cutscene_fadeouts = cutscene_fadeouts[str(cutscene_name)]
	
	current_cutscene = str(cutscene_name)
	currently_playing_cutscene = true
	
	show()
	NextCutscenePoint()
	
func NextCutscenePoint():
	if len(current_cutscene_text) == 0:	#failsave
		return
		
	var next_image = current_cutscene_images[0]
	current_cutscene_images.remove_at(0)
	$Background.texture = next_image
	
	var next_text = current_cutscene_text[0]
	current_cutscene_text.remove_at(0)
	$CutsceneText.text = next_text
	
	current_waittime_left = current_cutscene_fadeouts[0]
	current_cutscene_fadeouts.remove_at(0)
	
	
	
func ReadCutdataLines(cutdata_lines,file_name):
	var local_cutscene_text = []
	var local_cutscene_images = []
	var local_cutscene_fadeouts = []
	var parent_fadeout_time = get_parent().total_fadeout_time
	
	#print(all_cutscene_images)
	
	for l in cutdata_lines:
		var splitted = l.replace("/n","\n").split(";",false)
		local_cutscene_fadeouts.push_back(max(0.0,float(splitted[0])-parent_fadeout_time))
		local_cutscene_images.push_back(all_cutscene_images[splitted[1]])
		local_cutscene_text.push_back(splitted[2])
	
	cutscene_fadeouts[file_name] = local_cutscene_fadeouts
	cutscene_images[file_name] = local_cutscene_images
	cutscene_text[file_name] = local_cutscene_text

func hide():
	$Background.hide()
	$CutsceneText.hide()
	$BackBackground.hide()
	$BackBackground.self_modulate.a = 0
	
func show():
	$Background.show()
	$CutsceneText.show()
	$BackBackground.show()

func _ready():
	hide()
	
	#import all cutscene images
	var cutimg_files = DirAccess.get_files_at("assets/cutscene_images")
	for cutimg_file in cutimg_files:
		if len(cutimg_file.split(".",false)) != 2:
			continue
			
		var local_cutimg_texture = load("assets/cutscene_images/"+cutimg_file)
		all_cutscene_images[cutimg_file.split(".",false)[0]] = local_cutimg_texture
	
	#import all cutscene data
	var cutdata_files = DirAccess.get_files_at("cutscene_data")
	for cutdata_file in cutdata_files:
		if len(cutdata_file.split(".",false)) != 2:
			continue
		
		var cutdata_file_fr_fr = FileAccess.open("cutscene_data/" + cutdata_file,FileAccess.READ)
		var cutdata_lines = cutdata_file_fr_fr.get_as_text().split("\n",false)
		ReadCutdataLines(cutdata_lines,cutdata_file.split(".",false)[0])

	
func _process(dt):
	if currently_playing_cutscene:
		current_waittime_left -= dt
		if current_waittime_left <= 0:
			if len(current_cutscene_text) == 0:
				self.get_parent().initiate_scene_set(int(current_cutscene),get_parent().find_child("RoomViewRoot"),"CutsceneEnd")
			else:
				self.get_parent().initiate_scene_set(int(current_cutscene),get_parent().find_child("RoomViewRoot"),"CutsceneNext")
