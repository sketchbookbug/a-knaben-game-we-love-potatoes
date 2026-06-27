extends Node2D

func create_interactable(text="debug text"):
	var current_button = Button.new()
	current_button.text = text
	var lambda = func local_lambda(): button_pressed(current_button)
	current_button.pressed.connect(lambda)
	add_child(current_button)
	
func button_pressed(cb):
	print("hi")
	print(cb.text)

func _ready():
	create_interactable("debug")
	create_interactable("uwu")
	
func _process(dt):
	pass
