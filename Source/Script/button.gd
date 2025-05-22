extends Button

var playing : bool

func _on_pressed() -> void:
	if playing:
		AudioManager.StopAll()
		playing = false
	else:
		playing = true
		AudioManager.PlayBackgroundMusic()
