extends Node2D

# Ruta del menú principal (asegúrate de que sea la correcta en tu proyecto)
const RUTA_MENU_PRINCIPAL = "res://Escenas/Intro/menu_principal.tscn"

var bus_index: int

@onready var slider = $ControlVolumen # <-- Cambiado al nombre de tu nodo

func _ready() -> void:
	# 1. Buscamos el bus de audio
	bus_index = AudioServer.get_bus_index("Musica")
	if bus_index == -1:
		bus_index = AudioServer.get_bus_index("Master")
	
	# 2. Verificamos que el slider exista antes de asignarle el valor
	if slider != null:
		slider.value = AudioServer.get_bus_volume_db(bus_index)
	else:
		print("Error: No se encontró el nodo ControlVolumen. Revisa la jerarquía.")

func _on_control_volumen_value_changed(value: float) -> void:
	# El índice 0 SIEMPRE es el Master (todo el juego)
	AudioServer.set_bus_volume_db(0, value)
	# Si esto no silencia el juego, el problema es la conexión de la señal
	print("Enviando a Master: ", value)

func _on_atras_pressed() -> void:
	# 1. DETECTAR SI ESTAMOS EN PAUSA:
	# Si el padre de esta escena es tu CanvasLayer "InterfazPausa"
	if get_parent() and get_parent().name == "InterfazPausa":
		# Buscamos el nodo del menú de pausa (que ocultamos antes) para volverlo a mostrar
		# Asumiendo que el script de arriba está en un nodo hijo de InterfazPausa
		for hermano in get_parent().get_children():
			if hermano.name != "MenuOpciones":
				hermano.show()
		
		# Simplemente eliminamos esta instancia de opciones
		queue_free()
	
	# 2. DETECTAR SI VENIMOS DEL MENÚ PRINCIPAL:
	else:
		# Si no hay "padre de pausa", cambiamos de escena normalmente
		if Global.escena_anterior != "":
			get_tree().change_scene_to_file(Global.escena_anterior)
		else:
			# Ruta de respaldo por si acaso
			get_tree().change_scene_to_file("res://Escenas/Intro/menu_principal.tscn")

func _on_boton_pantalla_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
