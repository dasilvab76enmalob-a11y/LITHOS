extends Node2D

@export var rango_movimiento: int = 4

@onready var suelo: TileMapLayer = $"../../Suelo"
@onready var rango_capa: TileMapLayer = $"../../RangoMovimiento"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var celda_actual: Vector2i
var celdas_validas: Array[Vector2i] = []
var esta_seleccionado: bool = false
var moviendose: bool = false

# Guardamos la última dirección para saber qué animación de "parado" mostrar
var ultima_direccion: String = "abajo_derecha"

func _ready() -> void:
	if suelo:
		celda_actual = suelo.local_to_map(suelo.to_local(global_position))
		global_position = suelo.to_global(suelo.map_to_local(celda_actual))
	
	reproducir_parado()

func obtener_celda() -> Vector2i:
	return celda_actual

func marcar_seleccionado(estado: bool) -> void:
	esta_seleccionado = estado
	if esta_seleccionado:
		actualizar_rango_movimiento()
	else:
		if rango_capa:
			rango_capa.clear()

func actualizar_rango_movimiento() -> void:
	celdas_validas.clear()
	if not rango_capa: return
	rango_capa.clear()

	for x in range(-rango_movimiento, rango_movimiento + 1):
		for y in range(-rango_movimiento, rango_movimiento + 1):
			if abs(x) + abs(y) <= rango_movimiento:
				var c = celda_actual + Vector2i(x, y)
				if suelo.get_cell_source_id(c) != -1:
					celdas_validas.append(c)
					rango_capa.set_cell(c, 0, Vector2i(0, 0))

func esta_en_rango(celda: Vector2i) -> bool:
	return celda in celdas_validas

func moverse_a_celda(dest_celda: Vector2i) -> void:
	if moviendose: return
	moviendose = true
	
	var delta_celda = dest_celda - celda_actual
	
	# Calcular la distancia real en casillas (métricas de Manhattan para cuadrícula isométrica)
	var distancia = abs(delta_celda.x) + abs(delta_celda.y)
	
	if animation_player:
		if abs(delta_celda.x) >= abs(delta_celda.y):
			if delta_celda.x > 0:
				ultima_direccion = "abajo_derecha"
				animation_player.play("animaciones_caminar/caminar_abajo_derecha")
			else:
				ultima_direccion = "arriba_izquierda"
				animation_player.play("animaciones_caminar/caminar_arriba_izquierda")
		else:
			if delta_celda.y > 0:
				ultima_direccion = "abajo_izquierda"
				animation_player.play("animaciones_caminar/caminar_abajo_izquierda")
			else:
				ultima_direccion = "arriba_derecha"
				animation_player.play("animaciones_caminar/caminar_arriba_derecha")

	celda_actual = dest_celda
	
	if rango_capa:
		rango_capa.clear()

	var pos_destino = suelo.to_global(suelo.map_to_local(dest_celda))
	
	# Velocidad constante: 0.25 segundos por cada casilla de distancia
	var tiempo_por_casilla: float = 0.25
	var duracion_total = distancia * tiempo_por_casilla
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", pos_destino, duracion_total)
	await tween.finished
	
	reproducir_parado()
	
	moviendose = false
	
	var combate = get_tree().current_scene
	if combate and combate.has_method("deseleccionar_actual"):
		combate.deseleccionar_actual()

func reproducir_parado() -> void:
	if animation_player:
		var anim_nombre = "animaciones_parado/parado_" + ultima_direccion
		if animation_player.has_animation(anim_nombre):
			animation_player.play(anim_nombre)
