extends Node2D

@export var tile_map_principal: TileMapLayer  # Arrastra tu TileMapLayer principal aquí
@export var capa_rango: TileMapLayer          # Arrastra tu nodo CapaRango aquí
@export var rango_movimiento: int = 3         # Cantidad máxima de casillas que se puede mover
@export var source_id_azul: int = 1           # ID del TileSet para la baldosa de rango
@export var atlas_coord_azul: Vector2i = Vector2i(0, 0) # Coordenadas en el atlas de la baldosa azul

var celda_actual: Vector2i

func _ready() -> void:
	# Asegurar que el personaje comience alineado exactamente a la celda donde está visualmente
	if tile_map_principal:
		celda_actual = tile_map_principal.local_to_map(global_position)
		global_position = tile_map_principal.map_to_local(celda_actual)
		calcular_y_mostrar_rango()

func _unhandled_input(event: InputEvent) -> void:
	var direccion = Vector2i.ZERO
	
	# Mapeo de controles en ejes isométricos (ajusta según tus acciones de Input Map)
	if event.is_action_pressed("ui_right"):
		direccion = Vector2i(1, 0)
	elif event.is_action_pressed("ui_left"):
		direccion = Vector2i(-1, 0)
	elif event.is_action_pressed("ui_down"):
		direccion = Vector2i(0, 1)
	elif event.is_action_pressed("ui_up"):
		direccion = Vector2i(0, -1)
		
	if direccion != Vector2i.ZERO:
		intentar_mover(direccion)

func intentar_mover(dir: Vector2i) -> void:
	var celda_destino = celda_actual + dir
	
	# Validación clave: Verifica que el tile destino exista en el mapa principal (-1 significa que está vacío/fuera)
	if tile_map_principal.get_cell_source_id(celda_destino) != -1:
		celda_actual = celda_destino
		global_position = tile_map_principal.map_to_local(celda_actual)
		# Actualiza el rango tras moverse
		calcular_y_mostrar_rango()

func calcular_y_mostrar_rango() -> void:
	if not capa_rango or not tile_map_principal:
		return
		
	# Limpiar el rango pintado previamente
	capa_rango.clear()
	
	# Calcular casillas alcanzables usando BFS
	var alcanzables = calcular_bfs(celda_actual, rango_movimiento)
	
	# Pintar cada celda en la CapaRango
	for celda in alcanzables.keys():
		capa_rango.set_cell(celda, source_id_azul, atlas_coord_azul)

func calcular_bfs(inicio: Vector2i, limite: int) -> Dictionary:
	var visitados = {}
	var cola = [[inicio, limite]]
	visitados[inicio] = limite
	
	var direcciones = [
		Vector2i(1, 0), 
		Vector2i(-1, 0), 
		Vector2i(0, 1), 
		Vector2i(0, -1)
	]
	
	while cola.size() > 0:
		var actual = cola.pop_front()
		var pos_actual = actual[0]
		var mov_restante = actual[1]
		
		if mov_restante <= 0:
			continue
			
		for dir in direcciones:
			var vecino_pos = pos_actual + dir
			
			# Si el vecino no existe en el mapa principal (fuera del tilemap), se ignora
			if tile_map_principal.get_cell_source_id(vecino_pos) == -1:
				continue
				
			var nuevo_mov = mov_restante - 1
			if nuevo_mov >= 0:
				if not visitados.has(vecino_pos) or nuevo_mov > visitados[vecino_pos]:
					visitados[vecino_pos] = nuevo_mov
					cola.append([vecino_pos, nuevo_mov])
					
	return visitados
