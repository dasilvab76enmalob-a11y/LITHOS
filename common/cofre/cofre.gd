extends StaticBody2D

@onready var animation_player = $AnimationPlayer
@onready var area_interaccion = $Area2D
@onready var label_interactuar = $Interactuar 
@onready var menu_opciones = $MenuOpciones 
@onready var btn_si = $MenuOpciones/SI 
@onready var btn_no = $MenuOpciones/NO 
@onready var panel_recompensa = $PanelRecompensa 
@onready var label_recompensa = $PanelRecompensa/LabelRecompensa 

var abierto = false
var jugador_cerca = false
var esperando_cierre = false
var esperando_decision = false
var player_ref = null

func _ready() -> void:
	# Asegurarnos de que inicie cerrado usando el frame 0 de la animación "abrir_cofre"
	if animation_player.has_animation("abrir_cofre"):
		animation_player.play("abrir_cofre")
		animation_player.seek(0, true) # Salta instantáneamente al inicio (cuando está cerrado)
		animation_player.stop()       # Detiene la reproducción para que no se abra solo
	
	# Ocultamos la UI al iniciar
	if label_interactuar:
		label_interactuar.visible = false
	if menu_opciones:
		menu_opciones.visible = false
	if panel_recompensa:
		panel_recompensa.visible = false 
		
	# Conectamos las señales de los botones automáticamente por código
	if btn_si and not btn_si.pressed.is_connected(eleccion_si):
		btn_si.pressed.connect(eleccion_si)
	if btn_no and not btn_no.pressed.is_connected(eleccion_no):
		btn_no.pressed.connect(eleccion_no)

func _input(event: InputEvent) -> void:
	if not jugador_cerca:
		return
		
	# Paso 5: Si el cofre ya está abierto y se espera cerrar definitivamente con E
	if esperando_cierre and event.is_action_pressed("interactuar"):
		cerrar_cofre_definitivo()
		return

	# Paso 1: Si pulsa interactuar estando cerca, muestra las opciones
	if not abierto and not esperando_decision and event.is_action_pressed("interactuar"):
		mostrar_menu_decision()

# --- FLUJO DE LOS PASOS ---

func mostrar_menu_decision() -> void:
	esperando_decision = true
	
	if label_interactuar:
		label_interactuar.visible = false
		
	# 1. Bloquear / Congelar al jugador inmediatamente al mostrar la pregunta
	if player_ref and player_ref.has_method("congelar_movimiento"):
		player_ref.congelar_movimiento()
		
	if menu_opciones:
		menu_opciones.visible = true

# Paso 2: Si pulsa NO (Aquí se reanuda el movimiento)
func eleccion_no() -> void:
	esperando_decision = false
	
	if menu_opciones:
		menu_opciones.visible = false
	
	# Descongelar al jugador al rechazar abrirlo
	if player_ref and player_ref.has_method("descongelar_movimiento"):
		player_ref.descongelar_movimiento()
		
	if label_interactuar:
		label_interactuar.visible = true

# Paso 3: Si pulsa SI (Sigue congelado durante la animación y hasta cerrar el cofre)
func eleccion_si() -> void:
	esperando_decision = false
	abierto = true
	
	if menu_opciones:
		menu_opciones.visible = false
	
	# Realizar la animación de abrir
	animation_player.play("abrir_cofre")
	await animation_player.animation_finished
	
	# Paso 4: Mostrar el panel de recompensa (fondo + texto)
	if label_recompensa:
		label_recompensa.text = "Has obtenido una recompensa.\nPulsa E para cerrar el cofre."
	if panel_recompensa:
		panel_recompensa.visible = true
	
	esperando_cierre = true

# Paso 5: Cerrar definitivamente con E (Aquí se reanuda el movimiento al terminar)
func cerrar_cofre_definitivo() -> void:
	esperando_cierre = false
	
	if panel_recompensa:
		panel_recompensa.visible = false 
	
	animation_player.play("cerrar_cofre")
	await animation_player.animation_finished
	
	# Descongelar al jugador solo después de que se cierra por completo
	if player_ref and player_ref.has_method("descongelar_movimiento"):
		player_ref.descongelar_movimiento()
		
	area_interaccion.monitoring = false
	if label_interactuar:
		label_interactuar.visible = false

# --- DETECCIÓN DE ÁREA ---

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("player") or body.name == "Player") and not abierto:
		jugador_cerca = true
		player_ref = body
		if label_interactuar and not esperando_decision and not esperando_cierre:
			label_interactuar.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		jugador_cerca = false
		player_ref = null
		if label_interactuar:
			label_interactuar.visible = false
