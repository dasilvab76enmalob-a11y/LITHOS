extends AudioStreamPlayer

var musica_actual_ruta: String = ""
var bloquear_cambio: bool = false # <--- Nueva variable

func reproducir_musica(ruta: String, forzar: bool = false):
	# Si está bloqueado y no estamos forzando, no hacemos nada
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if bloquear_cambio and not forzar:
		return
		
	if musica_actual_ruta == ruta:
		return
	
	musica_actual_ruta = ruta
	stream = load(ruta)
	play()
