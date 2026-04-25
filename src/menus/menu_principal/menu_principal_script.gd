extends Control

# --- RUTAS ---
const RUTA_OPCIONES = "res://src/menus/menu_opciones/menu_opciones.tscn"
const RUTA_CARGA = "res://src/menus/pantalla_carga/pantalla_carga.tscn"
const RUTA_ESCENA_1 = "res://src/niveles/planeta_core/escena_1.tscn"

# --- NODOS ---
@onready var boton_continuar = $VBoxContainer/Continuar
@onready var panel_confirmacion = $PanelConfirmacion

func _ready() -> void:
	# Al entrar al menú, nos aseguramos de que la música suene.
	# .play() es una función nativa de AudioStreamPlayer (tu escena MusicaGlobal)
	if is_instance_valid(MusicaGlobal):
		if not MusicaGlobal.playing:
			MusicaGlobal.play()
	
	# Inicializar estado visual
	self.modulate.a = 1.0
	panel_confirmacion.hide()
	
	# Verificar si existe una partida guardada para mostrar el botón Continuar
	if FileAccess.file_exists("user://partida.save"):
		boton_continuar.show()
	else:
		boton_continuar.hide()

# --- LÓGICA DE BOTONES PRINCIPALES ---

func _on_nueva_partida_pressed() -> void:
	panel_confirmacion.show()

func _on_continuar_pressed() -> void:
	# Antes de ir a la carga, apagamos la música global
	if is_instance_valid(MusicaGlobal):
		MusicaGlobal.stop()
		
	if ResourceLoader.exists(RUTA_ESCENA_1):
																																	get_tree().change_scene_to_file(RUTA_ESCENA_1)

func _on_opciones_pressed() -> void:
	if ResourceLoader.exists(RUTA_OPCIONES):
		# Guardamos la ruta actual en el Singleton Global (el de datos, no el de música)
		Global.escena_anterior = scene_file_path
		
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.2)
		tween.tween_callback(func(): 
			get_tree().change_scene_to_file(RUTA_OPCIONES)
		)

func _on_salir_pressed() -> void:
	get_tree().quit()

# --- LÓGICA DEL PANEL DE CONFIRMACIÓN (SI/NO) ---

func _on_si_pressed() -> void:
	# 1. Crear/Sobrescribir el archivo de guardado
	var file = FileAccess.open("user://partida.save", FileAccess.WRITE)
	if file:
		file.store_string("Nueva Partida Iniciada")
		file.close()
	
	# 2. DETENER MÚSICA GLOBAL
	# Usamos .stop() directamente porque MusicaGlobal es un AudioStreamPlayer
	if is_instance_valid(MusicaGlobal):
		MusicaGlobal.stop()
	
	# 3. Transición a la escena 1
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
