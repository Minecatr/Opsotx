extends Decal

func _on_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
	tween.tween_callback(self.queue_free)
