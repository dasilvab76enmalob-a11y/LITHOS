extends StaticBody2D

@onready var animation_player = $AnimationPlayer
@onready var area_interaccion = $Area2D
@onready var label_interactuar = $Interactuar 

var jugador_cerca = false
var esta_abierta = false # Arranca cerrada por defecto

func _ready() -> void:
	# Al iniciar el juego, cargamos la posición base de reposo (cerrada)
	if animation_player.has_animation("ventana_inactiva"):
		animation_player.play("ventana_inactiva")
	
	if label_interactuar:
		label_interactuar.visible = false

func _input(event: InputEvent) -> void:
	if jugador_cerca and event.is_action_pressed("interactuar"):
		alternar_ventana()

func alternar_ventana() -> void:
	if esta_abierta:
		# Si está abierta, reproducimos la animación para cerrarla
		animation_player.play("ventana_cerrada")
		esta_abierta = false
	else:
		# Si está cerrada, reproducimos la animación para abrirla
		animation_player.play("ventana_abierta")
		esta_abierta = true

# --- DETECCIÓN DE ÁREA ---

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		jugador_cerca = true
		if label_interactuar:
			label_interactuar.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		jugador_cerca = false
		if label_interactuar:
			label_interactuar.visible = false
