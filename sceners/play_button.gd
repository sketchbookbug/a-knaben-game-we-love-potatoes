extends Button

func start_playing():
	get_tree().change_scene_to_file("res://sceners/zeppelin-room-scene.tscn")
	
func quit_game():
	get_tree().quit()

func _ready():
	if name == "PlayButton":
		pressed.connect(start_playing)
	else:
		pressed.connect(quit_game)
	
func _process(dt):
	pass
