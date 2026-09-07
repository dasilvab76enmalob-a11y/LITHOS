extends Node2D

@onready var barra_carga = $BarraDeCarga
@onready var label_continuar = $Label 

const TIEMPO_CARGA_TOTAL = 12.0 
const RUTA_SIGUIENTE_ESCENA = "res://src/menus/menu_principal/menu_principal.tscn"

var tiempo_transcurrido = 0.0
var carga_completa = false

func _ready() -> void:
	# Carga la del menú antes de entrar
	MusicaGlobal.reproducir_musica("res://assets/audio/soundtrack/Cracked Tempo - Pantalla de Carga.ogg")
	
	if barra_carga == null or label_continuar == null:
		return

	barra_carga.value = 0
	label_continuar.visible = false

func _process(delta: float) -> void:
	if not carga_completa:
		_actualizar_progreso(delta)
	else:
		if Input.is_action_just_pressed("ui_accept"): 
			_cambiar_de_escena()

func _actualizar_progreso(delta: float) -> void:
	tiempo_transcurrido += delta
	var progreso = clamp(tiempo_transcurrido / TIEMPO_CARGA_TOTAL, 0.0, 1.0)
	barra_carga.value = progreso * 100
	if progreso >= 1.0:
		_finalizar_espera()

func _finalizar_espera() -> void:
	if carga_completa: return 
	carga_completa = true
	barra_carga.visible = false
	label_continuar.visible = true
	_hacer_parpadear_texto()

func _hacer_parpadear_texto() -> void:
	# El bind_node asegura que el Tween se destruya si el nodo se libera
	var tween = create_tween().bind_node(label_continuar).set_loops()
	tween.tween_property(label_continuar, "modulate:a", 0.0, 0.8)
	tween.tween_property(label_continuar, "modulate:a", 1.0, 0.8)

func _cambiar_de_escena() -> void:
	# Matar todos los tweens activos antes de cambiar de escena para evitar errores
	for tween in get_tree().get_processed_tweens():
		tween.kill()
		
	get_tree().change_scene_to_file(RUTA_SIGUIENTE_ESCENA)
