extends AudioStreamPlayer2D

func preparar_y_sonar():
	if stream == null:
		stream = load("res://assets/audio/soundtrack/Cracked Tempo (2).mp3")
	
	bus = "Master"
	process_mode = Node.PROCESS_MODE_ALWAYS
	play()
