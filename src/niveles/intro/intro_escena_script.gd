extends Node2D

# Referencias a tus nodos. Asegúrate de que se llamen así.
@onready var color_rect_fondo = $ColorRect  # Tu fondo negro con Anchors en Full Rect
@onready var sprite_logo = $Sprite2D        # Tu logo de Estudios Bambuu

func _ready() -> void:
	# --- PASO 0: CONFIGURACIÓN INICIAL ---
	# Nos aseguramos de que el logo empiece TOTALMENTE INVISIBLE (Canal Alpha en 0)
	# Esto lo hacemos por código para que sea exacto, anulando lo del inspector.
	sprite_logo.modulate.a = 0.0
	
	# --- PASO 1: CREAR EL TWEEN PRINCIPAL ---
	# Un Tween es un "manejador de animaciones por código".
	var intro_tween = get_tree().create_tween()
	
	# --- PASO 2: LA LÍNEA DE TIEMPO (SECUENCIA) ---
	# Los Tweens en Godot 4 se ejecutan en ORDEN, uno tras otro por defecto.

	# A. ESPERA INICIAL (5 segundos de pantalla negra)
	# tween_interval no anima nada, solo pausa el Tween durante ese tiempo.
	intro_tween.tween_interval(5.0)
	
	# B. APARECER LENTAMENTE (FADE IN - 2.5 segundos)
	# Animamos modulate:a (Alpha) del logo de 0.0 a 1.0 (visible).
	# Usamos suavizados profesionales (TRANS_SINE, EASE_IN_OUT).
	intro_tween.tween_property(sprite_logo, "modulate:a", 1.0, 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# C. PAUSA DE VISIBILIDAD (2.0 segundos con el logo totalmente visible)
	# Para que el jugador pueda leer el nombre del estudio.
	intro_tween.tween_interval(10.0)
	
	# D. DESAPARECER LENTAMENTE (FADE OUT - 2.5 segundos)
	# Animamos modulate:a (Alpha) del logo de vuelta a 0.0 (invisible).
	intro_tween.tween_property(sprite_logo, "modulate:a", 0.0, 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# --- PASO 3: CONECTAR AL FINAL ---
	# Cuando TODA la secuencia de arriba termine, llamamos a la función para cambiar de escena.
	intro_tween.finished.connect(_al_terminar_secuencia)

func _al_terminar_secuencia():
	# Creamos un pequeño desvanecimiento final antes de cambiar
	var fade_final = get_tree().create_tween()
	
	fade_final.tween_property(sprite_logo, "modulate:a", 0.0, 1.0)
	fade_final.tween_interval(0.5)
	
	fade_final.finished.connect(func():
		# --- AQUÍ ACTIVAMOS LA MÚSICA ---
		# 'MusicaGlobal' es el nombre que le pusiste en el Autoload (Singleton)
		if MusicaGlobal.has_method("preparar_y_sonar"):
			MusicaGlobal.preparar_y_sonar()
		else:
			# Si no usaste el método personalizado, simplemente dale play
			MusicaGlobal.play()
			
		# Cambiamos a la pantalla de carga
		get_tree().change_scene_to_file("res://src/menus/pantalla_carga/pantalla_carga.tscn")
	)
