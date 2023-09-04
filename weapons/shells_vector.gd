extends GPUParticles3D

func _ready():
	restart()
func _process(delta):
	if !emitting:
		queue_free()
