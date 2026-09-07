extends Control

# --- RUTAS ---
const RUTA_MENU_PRINCIPAL = "res://src/menus/menu_principal/menu_principal.tscn"
@onready var escena_opciones = preload("res://src/menus/menu_opciones/menu_opciones.tscn")

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# Si el menú de opciones está abierto, no cerramos la pausa con ESC
		if not get_parent().has_node("MenuOpciones"):
			toggle_pause()

func toggle_pause() -> void:
	var nuevo_estado = !get_tree().paused
	get_tree().paused = nuevo_estado
	visible = nuevo_estado
	
	if nuevo_estado:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_continuar_pressed() -> void:
	toggle_pause()

func _on_opciones_pressed() -> void:
	var instancia = escena_opciones.instantiate()
	instancia.name = "MenuOpciones"
	# Lo metemos en el CanvasLayer (InterfazPausa) para que mantenga la escala
	get_parent().add_child(instancia)
	self.hide()

func _on_menu_principal_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(RUTA_MENU_PRINCIPAL)

func _on_salir_pressed() -> void:
	get_tree().quit()
