extends Control

enum EstadoCombate { TURNO_JUGADOR, TURNO_ENEMIGO, VICTORIA, DERROTA }
var estado_actual: EstadoCombate = EstadoCombate.TURNO_JUGADOR

@onready var jugador: Sprite2D = $VisualesCombate/PosicionJugador/Sprite2D
@onready var enemigo: Sprite2D = $VisualesCombate/PosicionEnemigo/Sprite2D
@onready var tile_map_suelo: TileMapLayer = $TileMapLayer         # El suelo rojo
@onready var tile_map_rango: TileMapLayer = $TileMapLayerRango  # La nueva capa exclusiva para el rango azul

@onready var barra_vida_jugador: ProgressBar = $CanvasLayer/VidaJugador
@onready var barra_vida_enemigo: ProgressBar = $CanvasLayer/VidaEnemigo
@onready var label_narrador: Label = $CanvasLayer/Panel/Label

@export var rango_movimiento: int = 3
var celdas_en_rango: Array[Vector2i] = []

# Configuración del TileSet para la capa de rango
@export var source_id_tile: int = 0
@export var atlas_coord_azul: Vector2i = Vector2i(0, 0) # La coordenada de tu baldosa azul en el TileSet

func _ready() -> void:
	inicializar_combate()
	
	if jugador and jugador.has_signal("seleccionado"):
		if not jugador.is_connected("seleccionado", _on_jugador_seleccionado):
			jugador.connect("seleccionado", _on_jugador_seleccionado)

func inicializar_combate() -> void:
	if jugador and "vida_maxima" in jugador:
		barra_vida_jugador.max_value = jugador.vida_maxima
		barra_vida_jugador.value = jugador.vida_actual
	
	if enemigo and "vida_maxima" in enemigo:
		barra_vida_enemigo.max_value = enemigo.vida_maxima
		barra_vida_enemigo.value = enemigo.vida_actual
		
	label_narrador.text = "Haz clic en Core para seleccionarlo."

func _on_jugador_seleccionado(_personaje: Combatiente) -> void:
	label_narrador.text = "Core seleccionado. Haz clic en una celda azul para moverte."
	mostrar_rango_movimiento()

func mostrar_rango_movimiento() -> void:
	limpiar_rango_movimiento()
	
	# Obtenemos en qué celda exacta del TileMap está parado el jugador
	var pos_tile_jugador = tile_map_suelo.local_to_map(tile_map_suelo.to_local(jugador.global_position))
	
	# Generamos el rombo de movimiento usando coordenadas de celda (Vector2i)
	for x in range(-rango_movimiento, rango_movimiento + 1):
		for y in range(-rango_movimiento, rango_movimiento + 1):
			if abs(x) + abs(y) <= rango_movimiento:
				var celda_destino = pos_tile_jugador + Vector2i(x, y)
				celdas_en_rango.append(celda_destino)
				
				# Pintamos exclusivamente en la capa superior de rango
				tile_map_rango.set_cell(celda_destino, source_id_tile, atlas_coord_azul)

func limpiar_rango_movimiento() -> void:
	# Limpiamos toda la capa de rango de un solo golpe, mucho más limpio y eficiente
	if tile_map_rango:
		tile_map_rango.clear()
	celdas_en_rango.clear()

# --- Detectamos el clic en el mapa para mover al personaje ---
func _input(event: InputEvent) -> void:
	if estado_actual != EstadoCombate.TURNO_JUGADOR:
		return
		
	if jugador and jugador.esta_seleccionado and not jugador.moviendose:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos = get_global_mouse_position()
			var celda_clic = tile_map_suelo.local_to_map(tile_map_suelo.to_local(mouse_pos))
			
			# Si la celda donde hicimos clic está dentro del rango calculado:
			if celda_clic in celdas_en_rango:
				var posicion_mundo_destino = tile_map_suelo.to_global(tile_map_suelo.map_to_local(celda_clic))
				
				limpiar_rango_movimiento()
				jugador.mover_a_posicion(posicion_mundo_destino)
				label_narrador.text = "Core se ha movido."

func _on_atacar_pressed() -> void:
	if estado_actual != EstadoCombate.TURNO_JUGADOR:
		return
	
	if jugador and enemigo:
		jugador.atacar(enemigo)
		barra_vida_enemigo.value = enemigo.vida_actual
		label_narrador.text = "¡Core atacó al enemigo!"
		
		if enemigo.vida_actual <= 0:
			label_narrador.text = "¡Has ganado!"
			estado_actual = EstadoCombate.VICTORIA
			return
	
	estado_actual = EstadoCombate.TURNO_ENEMIGO
	ejecutar_turno_enemigo()

func ejecutar_turno_enemigo() -> void:
	await get_tree().create_timer(1.2).timeout
	
	if enemigo and jugador:
		enemigo.atacar(jugador)
		barra_vida_jugador.value = jugador.vida_actual
		label_narrador.text = "¡El enemigo te ha atacado!"
		
		if jugador.vida_actual <= 0:
			label_narrador.text = "Has sido derrotado..."
			estado_actual = EstadoCombate.DERROTA
			return
	
	estado_actual = EstadoCombate.TURNO_JUGADOR
	label_narrador.text = "Tu turno. Haz clic en Core."
