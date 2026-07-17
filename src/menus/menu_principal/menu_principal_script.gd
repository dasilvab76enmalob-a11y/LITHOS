extends Control

# --- RUTAS ---
const RUTA_OPCIONES = "res://src/menus/menu_opciones/menu_opciones.tscn"
const RUTA_CARGA = "res://src/menus/pantalla_carga/pantalla_carga.tscn"
const RUTA_ESCENA_1 = "res://src/niveles/planeta_core/escena_1.tscn"
const RUTA_MUSICA_MENU = "res://assets/audio/soundtrack/The_Obsidian_Council - Menu Principal.ogg"
const RUTA_MUSICA_JUEGO = "res://assets/audio/soundtrack/Glasswind Path - Cinder Theme.ogg"

# --- NODOS ---
@onready var boton_continuar = $VBoxContainer/Continuar
@onready var panel_confirmacion = $PanelConfirmacion

func _ready() -> void:
	self.modulate.a = 1.0
	panel_confirmacion.hide()
	
	# Verificar si existe una partida guardada
	if FileAccess.file_exists("user://partida.save"):
		boton_continuar.show()
	else:
		boton_continuar.hide()
	
	# CORRECCIÓN DE LÓGICA:
	# Solo ponemos la música del menú si:
	# 1. No hay música sonando (estamos iniciando el juego).
	# 2. O si lo que está sonando NO es la música del juego (es decir, venimos de la carga inicial).
	# SI lo que suena es la música del juego, no hacemos NADA y dejamos que persista.
	if MusicaGlobal.musica_actual_ruta != RUTA_MUSICA_JUEGO:
		MusicaGlobal.reproducir_musica(RUTA_MUSICA_MENU)

# --- LÓGICA DE BOTONES PRINCIPALES ---

func _on_nueva_partida_pressed() -> void:
	panel_confirmacion.show()

func _on_continuar_pressed() -> void:
	MusicaGlobal.reproducir_musica(RUTA_MUSICA_JUEGO)
	if ResourceLoader.exists(RUTA_ESCENA_1):
		get_tree().change_scene_to_file(RUTA_ESCENA_1)

func _on_opciones_pressed() -> void:
	if ResourceLoader.exists(RUTA_OPCIONES):
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.2)
		tween.tween_callback(func(): 
			get_tree().change_scene_to_file(RUTA_OPCIONES)
		)

func _on_salir_pressed() -> void:
	get_tree().quit()

# --- LÓGICA DEL PANEL DE CONFIRMACIÓN (SI/NO) ---

func _on_si_pressed() -> void:
	var file = FileAccess.open("user://partida.save", FileAccess.WRITE)
	if file:
		file.store_string("Nueva Partida Iniciada")
		file.close()
	
	MusicaGlobal.reproducir_musica(RUTA_MUSICA_JUEGO)
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): 
		if ResourceLoader.exists(RUTA_ESCENA_1):
			get_tree().change_scene_to_file(RUTA_ESCENA_1)
		else:
			print("ERROR: No se encuentra la escena_1.tscn")
	)

func _on_no_pressed() -> void:
	panel_confirmacion.hide()
	self.modulate.a = 1.0
