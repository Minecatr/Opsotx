extends GPUParticles3D

func _ready():
	restart()
func _process(_delta):
	if !emitting:
		queue_free()
