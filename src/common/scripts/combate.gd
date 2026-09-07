extends Control

@onready var suelo: TileMapLayer = $Suelo
@onready var rango_movimiento_layer: TileMapLayer = $RangoMovimiento
@onready var unidades_contenedor: Node2D = $Unidades

var unidad_seleccionada = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var celda_clic = suelo.local_to_map(suelo.to_local(mouse_pos))
		
		# 1. Si ya hay una unidad seleccionada y hacemos clic en una celda válida de su rango
		if unidad_seleccionada and unidad_seleccionada.esta_en_rango(celda_clic):
			unidad_seleccionada.moverse_a_celda(celda_clic)
			return

		# 2. Comprobar si hicimos clic directamente sobre una unidad
		var unidad_encontrada = obtener_unidad_en_celda(celda_clic)
		if unidad_encontrada:
			seleccionar_unidad(unidad_encontrada)
		else:
			# 3. Si hicimos clic en el suelo vacío fuera de todo, deseleccionamos
			deseleccionar_actual()

func seleccionar_unidad(unidad) -> void:
	deseleccionar_actual()
	unidad_seleccionada = unidad
	unidad_seleccionada.marcar_seleccionado(true)
	print("Unidad seleccionada: ", unidad.name)

func deseleccionar_actual() -> void:
	if unidad_seleccionada:
		unidad_seleccionada.marcar_seleccionado(false)
		unidad_seleccionada = null
		rango_movimiento_layer.clear()
		print("Deseleccionado.")

func obtener_unidad_en_celda(cell_pos: Vector2i):
	for unidad in unidades_contenedor.get_children():
		if unidad.has_method("obtener_celda") and unidad.obtener_celda() == cell_pos:
			return unidad
	return null
