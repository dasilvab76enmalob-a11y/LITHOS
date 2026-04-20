extends CharacterBody3D

# Estas son las "Estadísticas" de tu personaje
@export var nombre: String = "Guerrero"
@export var movimiento_maximo: int = 5
@export var vida_maxima: int = 20
var vida_actual: int = 20

# Esta función se activa cuando haces clic
func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Has seleccionado a: ", nombre)
			seleccionar_unidad()

func seleccionar_unidad():
	# Aquí es donde luego pondremos las celdas azules de movimiento
	print("Vida: ", vida_actual, "/", vida_maxima)
	# Vamos a hacer que el personaje salte un poquito para que sepas que lo elegiste
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y + 0.5, 0.1)
	tween.tween_property(self, "position:y", position.y, 0.1)
