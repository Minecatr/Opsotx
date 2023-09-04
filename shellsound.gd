extends AudioStreamPlayer3D
@onready var soundlengths = [0.6807936508, 0.5789569161, 0.3323356009]
@onready var gs = $Gunshot
var l = 0;
var randn
func _ready():
	randn = round(randf()*3)
	for i in range(randn):
		var index = i + (3 - randn)
#		print(index)
		l += soundlengths[index]
	
func _process(delta):
	if get_playback_position() >= l:
		_on_finished()
	

func _on_finished():
	stop()
	if !gs:
		queue_free()

func _on_timer_timeout():
	var p = 0
	for i in range(randn):
		p += soundlengths[i]
	l += p
	play(p)


func _on_gunshot_finished():
	if !playing:
		queue_free()
	else:
		gs.queue_free()
