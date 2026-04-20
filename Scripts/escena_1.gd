extends Node2D

func _ready() -> void:
	# 1. Limpiamos cualquier instancia previa (por seguridad)
	Dialogic.clear() 
	
	# 2. Llamamos a la Timeline por su nombre EXACTO
	# Nota: El nombre es el que pusiste en la pestaña de Dialogic
	Dialogic.start("timeline_escena_1")
