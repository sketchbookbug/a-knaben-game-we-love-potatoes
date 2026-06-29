extends TextureRect


var MaxRotation = 45.0
var MaxRotationRandomChange = MaxRotation / 8
var RotationSpeed = 0.0
var rannumgen = RandomNumberGenerator.new()

func _ready():
	RotationSpeed = rannumgen.randf_range(-MaxRotation,MaxRotation)

func _process(dt):
	rotation_degrees += RotationSpeed * dt
#	if rotation_degrees < 0.0:
#		rotation_degrees = 0.0
#	if rotation_degrees > 360.0:
#		rotation_degrees = 360.0
	RotationSpeed += rannumgen.randf_range(-MaxRotationRandomChange,MaxRotationRandomChange) * dt
	if RotationSpeed > MaxRotation:
		RotationSpeed = MaxRotation
	if RotationSpeed < -MaxRotation:
		RotationSpeed = -MaxRotation
