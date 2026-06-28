extends Node2D

var currently_fading_out = false
var currently_fading_in = false
var current_scene_trans_id = 0
var current_scene_trans_child = null
var total_fadeout_time = 0.8
var fadeout_alpha_steps_in_a_second = 2 / total_fadeout_time	#1 over half of the total fadeout time
var background_images = {}

var current_scene = 0

func _ready():
	
	
	$FadeoutPolygon.self_modulate.a = 0
	$FadeoutPolygon.visible = false

	var background_files = DirAccess.get_files_at("assets/backgrounds")
	for bg_file in background_files:
		if len(bg_file.split(".",false)) != 2 or ".import" in bg_file:
			continue
			
		var local_bg_texture = load("assets/backgrounds/"+bg_file)
		background_images[int(bg_file.split(".",false)[0])] = local_bg_texture
	
	change_scene($RoomViewRoot,0)
	
	
func _start_FadeIn():
	$FadeoutPolygon.self_modulate.a = 1
	currently_fading_out = false
	currently_fading_in = true
	
	change_scene(current_scene_trans_child,current_scene_trans_id)
	
	
func _stop_Fadestuff():
	currently_fading_in = false
	currently_fading_out = false
	$FadeoutPolygon.self_modulate.a = 0
	$FadeoutPolygon.visible = false
	
func initiate_scene_set(id,child):
	currently_fading_in = false
	currently_fading_out = true
	current_scene_trans_id = id
	current_scene_trans_child = child
	
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
	if id in background_images.keys():
		$Background.texture = background_images[id]
	
func _process(dt):
	if currently_fading_out:
		$FadeoutPolygon.self_modulate.a += fadeout_alpha_steps_in_a_second * dt
		if $FadeoutPolygon.self_modulate.a >= 1:
			self._start_FadeIn()
	elif currently_fading_in:
		$FadeoutPolygon.self_modulate.a -= fadeout_alpha_steps_in_a_second * dt
		if $FadeoutPolygon.self_modulate.a <= 0:
			self._stop_Fadestuff()
