extends Node2D

@onready var anime = $AnimationPlayer
@onready var tiempo = $Timer

func _ready() -> void:
	# 1. Reproducir animación
	if anime.has_animation("new_animation"):
		anime.play("new_animation")
	
	# 2. CONEXIÓN SEGURA: Conectamos el timer por código por si olvidaste 
	# hacerlo en el editor. Así evitamos que se quede cargando para siempre.
	if not tiempo.timeout.is_connected(_on_timer_timeout):
		tiempo.timeout.connect(_on_timer_timeout)
	
	# 3. Configuración del Timer
	tiempo.wait_time = 10.0 # Ajusta los segundos que quieras que dure
	tiempo.one_shot = true
	tiempo.start()
	
	print("Timer iniciado correctamente...")

func _on_timer_timeout() -> void:
	print("¡Timer finalizado! Saltando a Escena 1...")
	
	# Cambiamos a la Escena 1. 
	# IMPORTANTE: Asegúrate de que esta ruta sea exacta (mayúsculas/minúsculas)
	var error = get_tree().change_scene_to_file("res://Escenas/escena_1.tscn")
	
	# Si la ruta estuviera mal, esto nos avisará en la consola
	if error != OK:
		print("ERROR: No se encontró la escena en res://Escenas/escena_1.tscn")
