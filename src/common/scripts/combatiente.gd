class_name Combatiente
extends Sprite2D

@export var nombre: String = "Core"
@export var vida_maxima: int = 100
var vida_actual: int

@export var tamano_celda: Vector2 = Vector2(32, 16)
@export var velocidad_movimiento: float = 0.15
var moviendose: bool = false
var esta_seleccionado: bool = false

signal seleccionado(personaje: Combatiente)

func _ready() -> void:
	vida_actual = vida_maxima

# --- Detección de clic directo sobre el personaje ---
func _input(event: InputEvent) -> void:
	if moviendose:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var rect = Rect2(global_position - Vector2(16, 24), Vector2(32, 48))
		
		if rect.has_point(mouse_pos):
			esta_seleccionado = true
			emit_signal("seleccionado", self)
			print("¡", nombre, " seleccionado!")

# --- Mover a una posición exacta del mundo (por clic en celda) ---
func mover_a_posicion(nueva_posicion: Vector2) -> void:
	if moviendose:
		return
		
	moviendose = true
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", nueva_posicion, velocidad_movimiento)
	
	await tween.finished
	moviendose = false
	esta_seleccionado = false # Deseleccionamos al terminar el movimiento

# --- Combate ---
func recibir_dano(cantidad: int) -> void:
	vida_actual -= cantidad
	vida_actual = clamp(vida_actual, 0, vida_maxima)
	print("%s recibió %d de daño. Vida restante: %d" % [nombre, cantidad, vida_actual])

func atacar(objetivo: Node) -> void:
	print("%s ataca" % nombre)
	if objetivo.has_method("recibir_dano"):
		objetivo.recibir_dano(20)
